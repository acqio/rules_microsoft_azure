load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def repositories():
    http_archive(
        name = "bazel_skylib",
        urls = ["https://github.com/bazelbuild/bazel-skylib/archive/1.0.2.tar.gz"],
        sha256 = "e5d90f0ec952883d56747b7604e2a15ee36e288bb556c3d0ed33e818a4d971f2",
        strip_prefix = "bazel-skylib-1.0.2",
    )
