workspace(name = "rules_microsoft_azure")

load("@rules_microsoft_azure//repositories:repositories.bzl", microsoft_azure_repositories = "repositories")

microsoft_azure_repositories()

load("@az//:extension.bzl", az_extension = "extension")

az_extension(
    name = "install_extension",
    extensions = {
        "databricks": "",
        "datafactory": "",
    },
)
