load("//az/private/common:common.bzl", "AZ_TOOLCHAIN", "common")
load("//az/private/common:utils.bzl", "utils")
load("//az:providers/providers.bzl", "AzConfigInfo")
load("//az/private:rules/storage/helpers.bzl", "helper")
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _impl(ctx):
    extension = ctx.attr.generator_function
    transitive_files = []
    transitive_files += ctx.files.srcs

    if hasattr(ctx.attr, "_action"):
        az_config = ctx.attr.config
        transitive_files += az_config[DefaultInfo].default_runfiles.files.to_list()

        az_action_arg = ctx.attr._action
        az_global_args = az_config[AzConfigInfo].global_args

        az_account_name_arg = ctx.attr.account_name.strip()
        if utils.check_stamping_format(ctx.attr.account_name):
            az_account_name_file = ctx.actions.declare_file(ctx.label.name + ".account-name")
            utils.resolve_stamp(ctx, ctx.attr.account_name, az_account_name_file)
            az_account_name_arg = "$(cat %s)" % az_account_name_file.short_path
            transitive_files.append(az_account_name_file)

        az_container_name_arg = ctx.attr.container_name.strip()
        if utils.check_stamping_format(ctx.attr.container_name):
            az_container_name_file = ctx.actions.declare_file(ctx.label.name + ".container-name")
            utils.resolve_stamp(ctx, ctx.attr.container_name, az_container_name_file)
            az_container_name_arg = "$(cat %s)" % az_container_name_file.short_path
            transitive_files.append(az_container_name_file)

        tpl_cmd = "$CLI_PATH {ext} {az_action_arg} {global_args}".format(
            ext = extension,
            az_action_arg = az_action_arg,
            global_args = az_global_args,
        )

        template_cmd = []

        for (srcs, container_path) in ctx.attr.srcs.items():
            for src in srcs.files.to_list():
                args_cmd = []
                destination_container = helper.resolved_destination_container(
                    src,
                    az_container_name_arg,
                    container_path,
                )

                if az_action_arg == "remove":
                    args_cmd = [
                        "--account-name \"%s\"" % az_account_name_arg,
                        "--container-name \"%s\"" % az_container_name_arg,
                        "--name \"%s\"" % destination_container.filepath,
                    ]
                else:
                    args_cmd = [
                        "--destination-account-name \"%s\"" % az_account_name_arg,
                        "--destination-container \"%s\"" % destination_container.destination,
                        "--source \"%s\"" % src.short_path,
                    ]
                template_cmd.append(" ".join([tpl_cmd] + args_cmd))

        template_substitutions = {
            "%{CLI_PATH}": ctx.var["AZ_PATH"],
            "%{CMD}": ";\n".join(template_cmd),
        }

    else:
        template_substitutions = {
            "%{CLI_PATH}": "ls -ahls",
            "%{CMD}": ";\n".join(["$CLI_PATH \"%s\"" % fp.short_path for fp in ctx.files.srcs]),
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
                transitive_files = depset(transitive_files),
            ),
            files = depset([ctx.outputs.executable]),
        ),
    ]

_common_attr = {
    "_resolved": attr.label(
        default = common.resolve_tpl,
        allow_single_file = True,
    ),
    "_stamper": attr.label(
        default = Label("//az/go/cmd/stamper"),
        executable = True,
        cfg = "host",
    ),
    "account_name": attr.string(
        mandatory = True,
    ),
    "config": attr.label(
        mandatory = True,
        providers = [AzConfigInfo],
    ),
    "container_name": attr.string(
        mandatory = True,
    ),
    "srcs": attr.label_keyed_string_dict(
        mandatory = True,
        allow_files = True,
    ),
}

_storage = rule(
    attrs = _common_attr,
    executable = True,
    toolchains = [AZ_TOOLCHAIN],
    implementation = _impl,
)

_storage_copy = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_action": attr.string(default = "copy"),
        },
    ),
    executable = True,
    toolchains = [AZ_TOOLCHAIN],
    implementation = _impl,
)

_storage_remove = rule(
    attrs = dicts.add(
        _common_attr,
        {
            "_action": attr.string(default = "remove"),
        },
    ),
    executable = True,
    toolchains = [AZ_TOOLCHAIN],
    implementation = _impl,
)

def storage(name, **kwargs):
    _storage(name = name, **kwargs)
    _storage_copy(name = name + ".copy", **kwargs)
    _storage_remove(name = name + ".remove", **kwargs)
