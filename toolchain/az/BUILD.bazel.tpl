"""
This BUILD file is auto-generated from toolchain/az/BUILD.bazel.tpl
"""
# package(default_visibility = ["//visibility:public"])

load("@rules_microsoft_azure//toolchain/az:toolchain.bzl", "az_toolchain")

az_toolchain(
    name = "toolchain",
    az_path = "%{AZ_PATH}",
    azure_extension_dir = "%{AZURE_EXTENSION_DIR}",
    visibility = ["//visibility:public"],
)

exports_files([
    "az.sh",
    "extension.bzl",
])

sh_binary(
    name = "cli",
    srcs = ["az.sh"],
    visibility = ["//visibility:public"],
)
