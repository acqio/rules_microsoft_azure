load(":versions.bzl", "versions")

def _install_or_update(repository_ctx, az, ext, ver):
    repository_ctx.report_progress("Installing extension (name: %s, version: %s)" % (ext, ver))

    check = repository_ctx.execute(
        [az, "extension", "remove", "--name", str(ext)],
        timeout = repository_ctx.attr.timeout,
        quiet = False,
    )

    result = repository_ctx.execute(
        [az, "extension", "add", "--yes", "--name", str(ext), "--version", ver],
        timeout = repository_ctx.attr.timeout,
        quiet = False,
    )

    if result.return_code:
        fail("Install extension failed: (stdout: %s, stderr: %s)" % (result.stdout, result.stderr))

def extensions(repository_ctx, az):
    repository_ctx.report_progress("Installation extensions for Azure CLI")
    for (e, v) in repository_ctx.attr.extensions.items():
        _install_or_update(repository_ctx, az, e, v)
