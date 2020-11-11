load("//az:providers/providers.bzl", "AzToolchainInfo")

def _az_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            info = AzToolchainInfo(
                az_extensions_installed = ctx.attr.az_extensions_installed,
                az_tool_path = ctx.attr.az_tool_path,
                az_tool_target = ctx.attr.az_tool_target,
                azure_extension_dir = ctx.attr.azure_extension_dir,
                jq_tool_path = ctx.attr.jq_tool_path,
            ),
        ),
        platform_common.TemplateVariableInfo({
            "AZURE_EXTENSION_DIR": str(ctx.attr.azure_extension_dir),
            "AZ_PATH": str(ctx.attr.az_tool_path),
            "JQ_PATH": str(ctx.attr.jq_tool_path),
        }),
    ]

az_toolchain = rule(
    implementation = _az_toolchain_impl,
    attrs = {
        "az_extensions_installed": attr.string_dict(
            allow_empty = True,
        ),
        "az_tool_path": attr.string(),
        "az_tool_target": attr.label(
            executable = True,
            allow_files = True,
            mandatory = True,
            cfg = "host",
        ),
        "azure_extension_dir": attr.string(),
        "jq_tool_path": attr.string(),
    },
)
