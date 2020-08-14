load("@bazel_skylib//lib:paths.bzl", "paths")
load("//az/private/common:common.bzl", "common")

BAZEL_PATH = "bazel"

def _pipeline_folder(ctx):
    base = paths.join(
        paths.join(BAZEL_PATH, ctx.workspace_name),
        paths.dirname(ctx.build_file_path),
    )
    return paths.normalize(base)

def _resolved_template(ctx):
    tpl = ctx.file.template
    out = ctx.actions.declare_file(common.substitutions_basename(ctx.attr.generator_name))
    args = ctx.actions.args()
    s_cmd = "."

    args.add(ctx.var["JQ_PATH"])
    args.add("-S --indent 4")
    if ctx.attr.subgroup == "pipeline":
        s_cmd = ".properties.folder.name = \"%s\"" % _pipeline_folder(ctx)
    args.add(s_cmd)
    args.add(tpl.path)
    args.add(out.path)

    ctx.actions.run_shell(
        inputs = [tpl],
        outputs = [out],
        command = "$1 $2 \"$3\" $4 > $5",
        arguments = [args],
    )

    return out

helper = struct(
    resolved_template = _resolved_template,
)
