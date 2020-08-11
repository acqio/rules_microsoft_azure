load(":versions.bzl", "versions")
load(":extensions.bzl", "extensions")

MINIMUM_AZ_CLI_VERSION = "2.10.1"

def _toolchain_configure_impl(repository_ctx):
    az_path = ""
    if repository_ctx.which("az"):
        az_path = str(repository_ctx.which("az"))
    else:
        fail("")

    azure_extension_dir = ""
    if repository_ctx.attr.azure_extension_dir:
        azure_extension_dir = repository_ctx.attr.azure_extension_dir
    elif "AZURE_EXTENSION_DIR" in repository_ctx.os.environ:
        azure_extension_dir = repository_ctx.os.environ["AZURE_EXTENSION_DIR"]
    elif "HOME" in repository_ctx.os.environ:
        azure_extension_dir = repository_ctx.os.environ["HOME"] + "/.azure/cliextensions"
    else:
        fail("")

    az_script_name = "az.sh"

    repository_ctx.file(
        az_script_name,
        content = """#!/usr/bin/env bash
# Immediately exit if any command fails.
set -e
export AZURE_EXTENSION_DIR="{0}"

{1} $*
""".format(azure_extension_dir, az_path),
        executable = True,
    )

    az_tool_target = "@%s//:%s" % (repository_ctx.name, az_script_name)
    az_tool_path = repository_ctx.path(az_script_name)

    repository_ctx.template(
        "BUILD.bazel",
        Label("@rules_microsoft_azure//az/toolchain:BUILD.bazel.tpl"),
        {
            "%{AZ_TOOL_PATH}": str(az_tool_path),
            "%{AZ_TOOL_TARGET}": az_tool_target,
            "%{AZURE_EXTENSION_DIR}": azure_extension_dir,
            "%{AZ_EXTENSIONS_INSTALLED}": str(repository_ctx.attr.extensions),
        },
        False,
    )

    az_cli_version = versions.get_az_cli_version(repository_ctx, az_tool_path)
    versions.check_az_cli_version(az_cli_version, MINIMUM_AZ_CLI_VERSION)
    extensions(repository_ctx, az_tool_path)

_toolchain_configure = repository_rule(
    implementation = _toolchain_configure_impl,
    attrs = {
        "azure_extension_dir": attr.string(
            mandatory = False,
            doc = "https://docs.microsoft.com/en-us/cli/azure/azure-cli-extensions-overview?view=azure-cli-latest",
        ),
        "extensions": attr.string_dict(
            mandatory = False,
        ),
        "timeout": attr.int(
            mandatory = False,
            default = 3600,
            doc = """Maximum duration of the extension manager execution in seconds.""",
        ),
    },
    environ = [
        "PATH",
    ],
)

def toolchain_configure(azure_extension_dir = None, extensions = {}, timeout = None):
    _toolchain_configure(
        name = "az",
        azure_extension_dir = azure_extension_dir,
        extensions = extensions,
        timeout = timeout,
    )

    native.register_toolchains("@rules_microsoft_azure//az/toolchain:linux_toolchain")
