"""
This BUILD file is auto-generated from toolchain/az/BUILD.bazel.tpl
"""

load("@rules_microsoft_azure//az/toolchain:toolchains.bzl", "az_toolchain")

az_toolchain(
    name = "toolchain",
    az_tool_path = "%{AZ_TOOL_PATH}",
    az_tool_target = "%{AZ_TOOL_TARGET}",
    azure_extension_dir = "%{AZURE_EXTENSION_DIR}",
    az_extensions_installed = %{AZ_EXTENSIONS_INSTALLED},
    jq_tool_path = "%{JQ_TOOL_PATH}",
    visibility = ["//visibility:public"],
)

exports_files([
    "az.sh",
])

sh_binary(
    name = "cli",
    srcs = ["az.sh"],
    visibility = ["//visibility:public"],
)
