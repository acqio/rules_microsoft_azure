def _toolchain_configure_impl(repository_ctx):
    az_path = ""
    if repository_ctx.which("az"):
        az_path = repository_ctx.which("az")
    else:
        fail("")

    # é bom definir um diretório no cache para armazenar apenas as extenções, e não misturar com as que já existem na cli.
    azure_extension_dir = ""
    if repository_ctx.attr.azure_extension_dir:
        azure_extension_dir = repository_ctx.attr.azure_extension_dir
    elif "AZURE_EXTENSION_DIR" in repository_ctx.os.environ:
        azure_extension_dir = repository_ctx.os.environ["AZURE_EXTENSION_DIR"]
    elif "HOME" in repository_ctx.os.environ:
        azure_extension_dir = repository_ctx.os.environ["HOME"] + "/.azure/cliextensions"
    else:
        fail("")

    print(az_path)
    print(azure_extension_dir)
    repository_ctx.template(
        "BUILD.bazel",
        Label("@rules_microsoft_azure//toolchain/az:BUILD.bazel.tpl"),
        {
            "%{AZ_PATH}": str(az_path),
            "%{AZURE_EXTENSION_DIR}": str(azure_extension_dir),
        },
        False,
    )

# Repository rule to generate a databricks_toolchain target
toolchain_configure = repository_rule(
    implementation = _toolchain_configure_impl,
    attrs = {
        "azure_extension_dir": attr.string(
            mandatory = False,
            doc = "https://docs.microsoft.com/en-us/cli/azure/azure-cli-extensions-overview?view=azure-cli-latest",
        ),
    },
    environ = [
        "PATH",
    ],
)
