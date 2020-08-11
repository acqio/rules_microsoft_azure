load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    "//az:providers/providers.bzl",
    "AzConfigInfo",
    "AzToolchainInfo",
)
load("//az/private/common:common.bzl", "common")

AZ_EXTENSION_NAME = "datafactory"
_AZ_TOOLCHAIN = "@rules_microsoft_azure//az/toolchain:toolchain_type"

_common_attr = {
    "stamp": attr.string(
        default = "",
    ),
    "config": attr.label(
        mandatory = True,
        providers = [AzConfigInfo],
    ),
}

def _impl(ctx):
    if not common.enable_rules(ctx.toolchains[_AZ_TOOLCHAIN].info.az_extensions_installed, AZ_EXTENSION_NAME):
        fail("This extension '{}' is not enabled.\n".format(AZ_EXTENSION_NAME) +
             "Configure the toolchain to enable this extension.")

    print("datafactory")

_datafactory = rule(
    # executable = True,
    toolchains = [_AZ_TOOLCHAIN],
    implementation = _impl,
    attrs = dicts.add(
        _common_attr,
        {
            "_command": attr.string(default = "ls"),
        },
    ),
)

def datafactory(name, **kwargs):
    _datafactory(name = name, **kwargs)
