load("@bazel_skylib//lib:paths.bzl", "paths")

def _resolved_destination_container(src, container_name, container_path):
    container_path = paths.normalize(container_path.strip())
    src_basename = paths.basename(src.short_path)

    if container_path.startswith("./") or container_path.startswith("/"):
        container_path = container_path.replace("./", "", 1).replace("/", "", 1)

    destination = paths.join(container_name, container_path)
    src_filepath = paths.join(container_path, src_basename)

    if container_path.startswith(".") or container_path == "":
        destination = container_name
        src_filepath = src_basename

    return struct(destination = destination, filepath = src_filepath)

helper = struct(
    resolved_destination_container = _resolved_destination_container,
)
