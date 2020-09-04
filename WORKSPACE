workspace(name = "rules_microsoft_azure")

load("@rules_microsoft_azure//az:deps.bzl", "az_config", "az_rules_repositories", "az_toolchain_configure")

az_rules_repositories()

az_toolchain_configure(
    extensions = {
        "datafactory": "0.1.0",
    },
)

az_config(
    name = "dev",
    debug = False,
    subscription = "dev-subscription",
    verbose = False,
)
