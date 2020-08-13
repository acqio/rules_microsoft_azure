load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    "//az:providers/providers.bzl",
    "AzConfigInfo",
)
load("//az/private/common:common.bzl", "common")
load("//az/private:rules/datafactory/helpers.bzl", "helper")

AZ_EXTENSION_NAME = "datafactory"
_AZ_TOOLCHAIN = "@rules_microsoft_azure//az/toolchain:toolchain_type"

_common_attr = {
    "factory_name": attr.string(
        mandatory = True,
    ),
    "resource_group": attr.string(
        mandatory = True,
    ),
    "subgroup": attr.string(
        mandatory = False,
        values = ["pipeline", "trigger"],
    ),
    "template": attr.label(
        mandatory = True,
        allow_single_file = [".json"],
    ),
    "config": attr.label(
        mandatory = True,
        providers = [AzConfigInfo],
    ),
}

def _impl(ctx):
    if common.check_enabled_extension(ctx.toolchains[_AZ_TOOLCHAIN].info.az_extensions_installed, AZ_EXTENSION_NAME):
        template_file = ctx.file.template
        files = [ctx.file.template]
        substitutions_file = ctx.actions.declare_file(common.substitutions_file_name(ctx.attr.generator_name))
        files += [substitutions_file]

        args = ctx.actions.args()
        args.add(ctx.var["JQ_PATH"])
        args.add("-S --indent 4")
        args.add(".properties.folder.name = \"{}\"".format(helper.pipeline_folder(ctx)))
        args.add(template_file.path)
        args.add(substitutions_file.path)

        ctx.actions.run_shell(
            inputs = [template_file],
            outputs = [substitutions_file],
            command = "$1 $2 \"$3\" $4 > $5",
            arguments = [args],
        )

        ctx.actions.expand_template(
            is_executable = True,
            output = ctx.outputs.executable,
            template = ctx.file._template,
            substitutions = {
                "%{JQ_CLI_PATH}": ctx.var["JQ_PATH"],
                "%{JQ_CLI_CMD}": "-M . %s" % substitutions_file.short_path,
            },
        )

        return [
            DefaultInfo(
                runfiles = ctx.runfiles(
                    files = files,
                ),
                files = depset([substitutions_file] + [ctx.outputs.executable]),
                executable = ctx.outputs.executable,
            ),
        ]

def _common_impl(ctx):
    if common.check_enabled_extension(ctx.toolchains[_AZ_TOOLCHAIN].info.az_extensions_installed, AZ_EXTENSION_NAME):
        files = []

        json_template_file = ""
        if hasattr(ctx.attr, "resolved"):
            json_template_file = ctx.attr.resolved[DefaultInfo].files.to_list()[0]
            files = [json_template_file]

        az_cmd = [AZ_EXTENSION_NAME, ctx.attr.subgroup, ctx.attr._action]
        az_cli_global_args = [
            ctx.attr.config[AzConfigInfo].global_args,
        ]
        az_cmd_args = [
            "--factory-name \"%s\"" % ctx.attr.factory_name,
            "--name \"%s\"" % ctx.attr.generator_name,
            "--resource-group \"%s\"" % ctx.attr.resource_group,
        ]

        if ctx.attr._action == "create":
            if ctx.attr.subgroup == "pipeline":
                az_cmd_args.append("--pipeline")
                az_cmd_args.append("@%s" % json_template_file.short_path)

        ctx.actions.expand_template(
            is_executable = True,
            output = ctx.outputs.executable,
            template = ctx.file._template,
            substitutions = {
                "%{AZ_CLI_PATH}": ctx.var["AZ_PATH"],
                "%{AZ_CLI_CMD}": " ".join(az_cmd),
                "%{AZ_CLI_GLOBAL_ARGS}": " ".join(az_cli_global_args),
                "%{AZ_CLI_CMD_ARGS}": " ".join(az_cmd_args),
            },
        )

        return [
            DefaultInfo(
                runfiles = ctx.runfiles(
                    files = files,
                ),
                executable = ctx.outputs.executable,
            ),
        ]

_datafactory = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_template": attr.label(
                default = common.resolve_tpl,
                allow_single_file = True,
            ),
        },
    ),
    executable = True,
    toolchains = [_AZ_TOOLCHAIN],
    implementation = _impl,
)

_datafactory_show = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_action": attr.string(default = "show"),
            "_template": attr.label(
                default = common.script_tpl,
                allow_single_file = True,
            ),
        },
    ),
    executable = True,
    toolchains = [_AZ_TOOLCHAIN],
    implementation = _common_impl,
)

_datafactory_create = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_action": attr.string(default = "create"),
            "resolved": attr.label(
                cfg = "target",
                executable = True,
                allow_files = True,
            ),
            "_template": attr.label(
                default = common.script_tpl,
                allow_single_file = True,
            ),
        },
    ),
    executable = True,
    toolchains = [_AZ_TOOLCHAIN],
    implementation = _common_impl,
)

_datafactory_delete = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_action": attr.string(default = "delete"),
            "_template": attr.label(
                default = common.script_tpl,
                allow_single_file = True,
            ),
        },
    ),
    executable = True,
    toolchains = [_AZ_TOOLCHAIN],
    implementation = _common_impl,
)

def datafactory(name, **kwargs):
    _datafactory(name = name, **kwargs)
    _datafactory_show(name = name + ".show", **kwargs)
    _datafactory_create(name = name + ".create", resolved = name, **kwargs)
    _datafactory_delete(name = name + ".delete", **kwargs)
