workspace(name = "rules_microsoft_azure")

load("@rules_microsoft_azure//az:deps.bzl", "az_rules_repositories", "az_toolchain_configure")

az_rules_repositories()
az_toolchain_configure(
  extensions = {
    "databricks": "0.5.0",
    "datafactory": "0.1.0",
  }
)

register_toolchains("@rules_microsoft_azure//az/toolchain:default_linux_toolchain")
