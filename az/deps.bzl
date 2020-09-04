load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("//az/toolchain:configure.bzl", _az_toolchain_configure = "toolchain_configure")
load("//az/private:rules/config.bzl", _az_config = "config_alias")

az_toolchain_configure = _az_toolchain_configure
az_config = _az_config

def az_dependencies():
    go_rules_dependencies()

    go_register_toolchains()
