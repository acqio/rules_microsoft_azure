load("//az/providers:providers.bzl", "AzConfigInfo")

def _impl(ctx):
    return [
        AzConfigInfo(
            debug = ctx.attr.debug,
            subscription = ctx.attr.subscription,
            tenant_id = ctx.attr.tenant_id,
            verbose = ctx.attr.verbose,
        ),
    ]

az_config = rule(
    implementation = _impl,
    attrs = {
        "debug": attr.bool(
            default = False,
        ),
        "subscription": attr.string(
            mandatory = True,
        ),
        "tenant_id": attr.string(),
        "verbose": attr.bool(
            default = False,
        ),
    },
)
