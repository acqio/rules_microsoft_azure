AzToolchainInfo = provider(
    doc = "Azure toolchain rule parameters",
    fields = [
        "az_path",
        "azure_extension_dir",
    ],
)

def _az_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            info = AzToolchainInfo(
                az_path = ctx.attr.az_path,
                azure_extension_dir = ctx.attr.azure_extension_dir,
            ),
        ),
        platform_common.TemplateVariableInfo({
            "AZ_PATH": str(ctx.attr.az_path),
            "AZURE_EXTENSION_DIR": str(ctx.attr.azure_extension_dir),
        }),
    ]

az_toolchain = rule(
    implementation = _az_toolchain_impl,
    attrs = {
        "az_path": attr.string(),
        "azure_extension_dir": attr.string(),
    },
)
