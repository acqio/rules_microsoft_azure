load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("//az:providers/providers.bzl", "AzConfigInfo")
load("//az/private/common:common.bzl", "AZ_TOOLCHAIN", "common")
load("//az/private/common:utils.bzl", "utils")
load("//az/private:rules/datafactory/helpers.bzl", "helper")

def _impl(ctx):
    extension = ctx.attr.generator_function

    if common.check_enabled_extension(ctx, extension):
        substitutions_file = helper.resolved_template(ctx)
        files = [substitutions_file]
        transitive_files = []

        template_substitutions = {
            "%{CLI_PATH}": ctx.var["JQ_PATH"],
            "%{CMD}": "$CLI_PATH -M . %s" % substitutions_file.short_path,
        }

        if hasattr(ctx.attr, "_action"):
            az_config = ctx.attr.config

            az_action_arg = ctx.attr._action
            az_resource_arg = ctx.attr.resource
            az_global_args = az_config[AzConfigInfo].global_args

            transitive_files += az_config[DefaultInfo].default_runfiles.files.to_list()

            factory_name_arg = "--factory-name \"%s\"" % ctx.attr.factory_name

            if utils.check_stamping_format(ctx.attr.factory_name):
                factory_name_file = ctx.actions.declare_file(ctx.label.name + ".factory_name-name")
                utils.resolve_stamp(ctx, ctx.attr.factory_name, factory_name_file)
                factory_name_arg = "--factory-name $(cat \"%s\")" % factory_name_file.short_path
                transitive_files.append(factory_name_file)

            resource_group_arg = "--resource-group \"%s\"" % ctx.attr.resource_group

            if utils.check_stamping_format(ctx.attr.resource_group):
                resource_group_file = ctx.actions.declare_file(ctx.label.name + ".resource_group-name")
                utils.resolve_stamp(ctx, ctx.attr.resource_group, resource_group_file)
                resource_group_arg = "--resource-group $(cat \"%s\")" % resource_group_file.short_path
                transitive_files.append(resource_group_file)

            template_cmd = [
                "$CLI_PATH",
                extension,
                az_resource_arg,
                az_action_arg,
                az_global_args,
                factory_name_arg,
                "--name \"%s\"" % ctx.attr.resource_name,
                resource_group_arg,
            ]

            if az_action_arg == "create":
                template_cmd += [
                    "--%s @%s" % (
                        "properties" if not az_resource_arg == "pipeline" else az_resource_arg,
                        substitutions_file.short_path,
                    ),
                ]

            template_substitutions = {
                "%{CLI_PATH}": ctx.var["AZ_PATH"],
                "%{CMD}": " ".join(template_cmd),
            }

        ctx.actions.expand_template(
            is_executable = True,
            output = ctx.outputs.executable,
            template = ctx.file._resolved,
            substitutions = template_substitutions,
        )

        return [
            DefaultInfo(
                runfiles = ctx.runfiles(
                    files = files,
                    transitive_files = depset(transitive_files),
                ),
                files = depset(files + [ctx.outputs.executable]),
            ),
        ]

_common_attr = {
    "_resolved": attr.label(
        default = common.resolve_tpl,
        allow_single_file = True,
        cfg = "host",
    ),
    "_stamper": attr.label(
        default = Label("//az/go/cmd/stamper"),
        executable = True,
        cfg = "host",
    ),
    "config": attr.label(
        mandatory = True,
        providers = [AzConfigInfo],
    ),
    "factory_name": attr.string(
        mandatory = True,
    ),
    "resource": attr.string(
        mandatory = False,
        values = ["pipeline", "trigger"],
    ),
    "resource_group": attr.string(
        mandatory = True,
    ),
    "resource_name": attr.string(
        mandatory = True,
    ),
    "template": attr.label(
        mandatory = True,
        allow_single_file = [".json"],
    ),
}

_datafactory = rule(
    attrs = _common_attr,
    executable = True,
    toolchains = [AZ_TOOLCHAIN],
    implementation = _impl,
)

_datafactory_create = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_action": attr.string(default = "create"),
        },
    ),
    executable = True,
    toolchains = [AZ_TOOLCHAIN],
    implementation = _impl,
)

_datafactory_delete = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_action": attr.string(default = "delete"),
        },
    ),
    executable = True,
    toolchains = [AZ_TOOLCHAIN],
    implementation = _impl,
)

_datafactory_show = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_action": attr.string(default = "show"),
        },
    ),
    executable = True,
    toolchains = [AZ_TOOLCHAIN],
    implementation = _impl,
)

_datafactory_start = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_action": attr.string(default = "start"),
        },
    ),
    executable = True,
    toolchains = [AZ_TOOLCHAIN],
    implementation = _impl,
)

_datafactory_stop = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_action": attr.string(default = "stop"),
        },
    ),
    executable = True,
    toolchains = [AZ_TOOLCHAIN],
    implementation = _impl,
)

def datafactory(name, **kwargs):
    _datafactory(name = name, **kwargs)
    _datafactory_create(name = name + ".create", **kwargs)
    _datafactory_delete(name = name + ".delete", **kwargs)
    _datafactory_show(name = name + ".show", **kwargs)

    if "resource" in kwargs and kwargs["resource"] == "trigger":
        _datafactory_start(name = name + ".start", **kwargs)
        _datafactory_stop(name = name + ".stop", **kwargs)
