load("//az:providers/providers.bzl", "AzConfigInfo")

def _impl(ctx):
    if ctx.attr.subscription.strip() == "":
        fail("The subscription attribute cannot be an empty string.")

    debug = "--debug" if ctx.attr.debug else ""
    subscription = "--subscription \"%s\"" % ctx.attr.subscription if ctx.attr.subscription.strip() != "" else ""
    verbose = "--verbose" if ctx.attr.verbose else ""

    return [
        AzConfigInfo(
            debug = ctx.attr.debug,
            subscription = ctx.attr.subscription,
            verbose = ctx.attr.verbose,
            global_args = " ".join([debug, subscription, verbose]),
        ),
    ]

config = rule(
    implementation = _impl,
    attrs = {
        "debug": attr.bool(
            default = False,
        ),
        "subscription": attr.string(
            mandatory = True,
        ),
        "verbose": attr.bool(
            default = False,
        ),
    },
)

def _impl_alias(repository_ctx):
    repository_ctx.file(
        "BUILD.bazel",
        content = """
load("@rules_microsoft_azure//az:defs.bzl", "az_config")

az_config(
    name = "config",
    debug = {debug},
    subscription = "{subscription}",
    verbose = {verbose},
    visibility = ["//visibility:public"],
)
""".format(
            debug = repository_ctx.attr.debug,
            subscription = repository_ctx.attr.subscription,
            verbose = repository_ctx.attr.verbose,
        ),
    )

config_alias = repository_rule(
    implementation = _impl_alias,
    attrs = {
        "debug": attr.bool(default = False),
        "subscription": attr.string(mandatory = True),
        "verbose": attr.bool(default = False),
    },
)
