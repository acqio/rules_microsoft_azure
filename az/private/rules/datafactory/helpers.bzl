load("@bazel_skylib//lib:paths.bzl", "paths")
load("//az/private/common:common.bzl", "common")

BAZEL_PATH = "bazel"

def _pipeline_folder(ctx):
    basepath = paths.join(
        paths.join(BAZEL_PATH, ctx.workspace_name),
        paths.dirname(ctx.build_file_path),
    )
    return paths.normalize(basepath)

def _resolved_template(ctx):
    template = ctx.file.template
    output = ctx.actions.declare_file(common.substitutions_file_name(ctx.attr.generator_name))

    args = ctx.actions.args()
    args.add(ctx.var["JQ_PATH"])
    args.add("-S --indent 4")
    subcommand = "."
    if ctx.attr.subgroup == "pipeline":
        subcommand = ".properties.folder.name = \"%s\"" % _pipeline_folder(ctx)
    args.add(subcommand)
    args.add(template.path)
    args.add(output.path)

    ctx.actions.run_shell(
        inputs = [template],
        outputs = [output],
        command = "$1 $2 \"$3\" $4 > $5",
        arguments = [args],
    )

    return output

helper = struct(
    resolved_template = _resolved_template,
)
