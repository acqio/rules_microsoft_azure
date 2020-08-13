load("@bazel_skylib//lib:paths.bzl", "paths")

BAZEL_PATH = "bazel"

def _pipeline_folder(ctx):
    basepath = paths.join(
        paths.join(BAZEL_PATH, ctx.workspace_name),
        paths.dirname(ctx.build_file_path),
    )
    return paths.normalize(basepath)

helper = struct(
    pipeline_folder = _pipeline_folder,
)
