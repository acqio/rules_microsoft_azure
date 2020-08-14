# Microsoft Azure Rules for [Bazel](https://bazel.build)

## Overview

This repository contains rules for interacting with Microsoft Azure.

NOTE: **These rules require azure cli.** For installation turn on [Microsoft documentation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

NOTE: This will only work on systems with Azure CLI >=2.10.1

## Setup

Add the following to your WORKSPACE file:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_microsoft_azure",
    urls = ["https://github.com/acqio/rules_microsoft_azure/archive/<revision>.tar.gz"],
    strip_prefix = "rules_microsoft_azure-<revision>",
    sha256 = "rules_microsoft_azure-<revision>",
)

load(
  "@rules_microsoft_azure//az:deps.bzl",
  "az_rules_repositories",
  # OPTIONAL
  "az_toolchain_configure"
)

az_rules_repositories()

# BEGIN OPTIONAL segment:
# These targets generate an executable to launch the Azure CLI.
# Note that this is only necessary if you want to add extensions or change Toolchain execution properties.
az_toolchain_configure(
    # OPTIONAL: You can define the directory that Azure CLI installs extensions to.
    # This value can be changed with respect to the default Azure CLI directory. Default: "~/.azure/cliextensions"
    azure_extension_dir = "~/.azure/cliextensions",
    # OPTIONAL: Call this to install extensions for the Azure CLI.
    # When installing extensions to the Azure CLI the process may time out before the operation is complete.
    extensions = {
        "datafactory": "0.1.0",
    },
    # OPTIONAL: Set the maximum duration for the extension manager to run in seconds. Default: 3600.
    timeout = 3600
)
# BEGIN OPTIONAL.
```

## Simple usage

The rules_databricks target can be used as executables for custom actions or can be executed directly by Bazel. For example, you can run:
```python
bazel run @az//:cli -- -h
```

## Set up Authentication

To [authenticate](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest) to Azure CLI:
```python
bazel run @az//:cli -- login
```

## Rules

* [az_config](docs/az_config.md)
* [az_datafactory](docs/az_datafactory.md)
