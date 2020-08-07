load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("//az/providers:providers.bzl", "AzConfigInfo")

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
    #   print(ctx.toolchains[_AZ_TOOLCHAIN].info)
    #   print(ctx.attr.config[AzConfigInfo])
    print("outracoisa")

_az_datafactory = rule(
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

def az_datafactory(name, **kwargs):
    _az_datafactory(name = name, **kwargs)
