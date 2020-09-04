load("//az:providers/providers.bzl", "AzConfigInfo")
load("//az/private/common:utils.bzl", "utils")

def _impl(ctx):
    if ctx.attr.subscription.strip() == "":
        fail("The subscription attribute cannot be an empty string.")

    debug_arg = "--debug" if ctx.attr.debug else ""
    subscription_arg = "--subscription \"%s\"" % ctx.attr.subscription
    verbose_arg = "--verbose" if ctx.attr.verbose else ""
    files = []

    if utils.check_stamping_format(ctx.attr.subscription):
        subscription_file = ctx.actions.declare_file(ctx.label.name + ".subscription-name")
        utils.resolve_stamp(ctx, ctx.attr.subscription, subscription_file)
        subscription_arg = "--subscription $(cat \"%s\")" % subscription_file.short_path
        files.append(subscription_file)

    return [
        AzConfigInfo(
            debug = ctx.attr.debug,
            global_args = " ".join([debug_arg, subscription_arg, verbose_arg]),
            subscription = ctx.attr.subscription,
            verbose = ctx.attr.verbose,
        ),
        DefaultInfo(
            runfiles = ctx.runfiles(
                files = files,
            ),
        ),
    ]

config = rule(
    implementation = _impl,
    attrs = {
        "_stamper": attr.label(
            default = Label("//az/go/cmd/stamper"),
            executable = True,
            cfg = "host",
        ),
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
