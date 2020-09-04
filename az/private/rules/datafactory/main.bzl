load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("//az:providers/providers.bzl", "AzConfigInfo")
load("//az/private/common:common.bzl", "AZ_TOOLCHAIN", "common")
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
            az_action = ctx.attr._action
            az_resource = ctx.attr.resource

            transitive_files += az_config[DefaultInfo].default_runfiles.files.to_list()

            template_cmd = [
                "$CLI_PATH",
                extension,
                az_resource,
                az_action,
                az_config[AzConfigInfo].global_args,
                "--factory-name \"%s\"" % ctx.attr.factory_name,
                "--name \"%s\"" % ctx.attr.resource_name,
                "--resource-group \"%s\"" % ctx.attr.resource_group,
            ]

            if az_action == "create":
                template_cmd += [
                    "--%s @%s" % (
                        "properties" if not az_resource == "pipeline" else az_resource,
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
