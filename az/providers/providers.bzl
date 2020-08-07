AzToolchainInfo = provider(
    doc = "Azure toolchain rule parameters",
    fields = ["az_tool_path", "az_tool_target", "azure_extension_dir", "az_extensions_installed"],
)

AzConfigInfo = provider(
    fields = ["debug", "subscription", "tenant_id", "verbose"],
)
