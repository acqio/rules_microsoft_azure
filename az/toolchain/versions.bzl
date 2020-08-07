def _get_az_cli_version(repository_ctx, az):
    result = repository_ctx.execute([az, "version", "-o", "tsv", "--query", "\"azure-cli\""])

    if result.return_code:
        fail("\nAzure CLI failed: (stdout: %s, stderr: %s)" % (result.stdout, result.stderr))

    return str(result.stdout).replace("\n", "")

def _extract_version_number(version):
    for i in range(len(version)):
        c = version[i]
        if not (c.isdigit() or c == "."):
            return version[:i]
    return version

def _parse_version(version):
    version = _extract_version_number(version)
    return tuple([int(n) for n in version.split(".")])

def _check_az_cli_version(az_cli_version = None, minimum_az_cli_version = None):
    if _parse_version(az_cli_version) < _parse_version(minimum_az_cli_version):
        fail("\nCurrent Azure CLI version is {}, expected at least {}\n".format(
            az_cli_version,
            minimum_az_cli_version,
        ))

versions = struct(
    get_az_cli_version = _get_az_cli_version,
    check_az_cli_version = _check_az_cli_version,
)
