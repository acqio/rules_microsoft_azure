def _extension(repository_ctx):
    repository_ctx.report_progress("Installation extensions for Azure CLI")
    az = repository_ctx.path(Label("%{LABEL_SCRIPT_AZ}"))

    for (e, v) in repository_ctx.attr.extensions.items():
        if v == "":
            v = "latest"

        repository_ctx.report_progress("Installing extension (name: %s, version: %s)" % (e, v))
        result = repository_ctx.execute(
            [az, "extension", "add", "--yes", "--name", str(e), "--version", v],
            timeout = repository_ctx.attr.timeout,
            quiet = False,
        )

        if result.return_code:
            fail("Install extension failed: (stdout: %s, stderr: %s)" % (result.stdout, result.stderr))

extension = repository_rule(
    implementation = _extension,
    attrs = {
        "extensions": attr.string_dict(
            mandatory = False,
        ),
        "timeout": attr.int(
            mandatory = False,
            default = 3600,
            doc = """Maximum duration of the extension manager execution in seconds.""",
        ),
    },
    environ = [
        "PATH",
    ],
)
