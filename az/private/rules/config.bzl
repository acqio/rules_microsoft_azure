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
