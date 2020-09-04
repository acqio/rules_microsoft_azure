def _check_stamping_format(f):
    if f.startswith("{") and f.endswith("}"):
        return True
    return False

def _resolve_stamp(ctx, string, output):
    stamps = [ctx.info_file, ctx.version_file]
    args = ctx.actions.args()
    args.add_all(stamps, format_each = "--stamp-info-file=%s")
    args.add(string, format = "--format=%s")
    args.add(output, format = "--output=%s")
    ctx.actions.run(
        executable = ctx.executable._stamper,
        arguments = [args],
        inputs = stamps,
        tools = [ctx.executable._stamper],
        outputs = [output],
        mnemonic = "Stamp",
    )

utils = struct(
    resolve_stamp = _resolve_stamp,
    check_stamping_format = _check_stamping_format,
)
