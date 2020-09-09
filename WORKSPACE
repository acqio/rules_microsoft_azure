workspace(name = "rules_microsoft_azure")

load("@rules_microsoft_azure//az:repositories.bzl", az_repositories = "repositories")

az_repositories()

load(
    "@rules_microsoft_azure//az:deps.bzl",
    "az_config",
    "az_dependencies",
    "az_toolchain_configure",
)

az_dependencies()

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

az_toolchain_configure(
    extensions = {
        "datafactory": "0.1.0",
    },
)

az_config(
    name = "dev",
    debug = False,
    subscription = "{STABLE_AZ_SUBSCRIPTION}",
    verbose = False,
)
