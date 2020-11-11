load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def repositories():
    bazel_skylib_version = "1.0.2"
    bazel_skylib_sha = "e5d90f0ec952883d56747b7604e2a15ee36e288bb556c3d0ed33e818a4d971f2"
    http_archive(
        name = "bazel_skylib",
        urls = ["https://github.com/bazelbuild/bazel-skylib/archive/%s.tar.gz" % bazel_skylib_version],
        sha256 = bazel_skylib_sha,
        strip_prefix = "bazel-skylib-%s" % bazel_skylib_version,
    )

    io_bazel_rules_go_version = "0.23.5"
    io_bazel_rules_go_sha = "2d536797707dd1697441876b2e862c58839f975c8fc2f0f96636cbd428f45866"
    http_archive(
        name = "io_bazel_rules_go",
        sha256 = io_bazel_rules_go_sha,
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/" +
            "download/v{0}/rules_go-v{0}.tar.gz".format(io_bazel_rules_go_version),
            "https://github.com/bazelbuild/rules_go/releases/" +
            "download/v{0}/rules_go-v{0}.tar.gz".format(io_bazel_rules_go_version),
        ],
    )

    bazel_gazelle_version = "0.21.1"
    bazel_gazelle_sha = "cdb02a887a7187ea4d5a27452311a75ed8637379a1287d8eeb952138ea485f7d"
    http_archive(
        name = "bazel_gazelle",
        sha256 = bazel_gazelle_sha,
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/" +
            "download/v{0}/bazel-gazelle-v{0}.tar.gz".format(bazel_gazelle_version),
            "https://github.com/bazelbuild/bazel-gazelle/releases/" +
            "download/v{0}/bazel-gazelle-v{0}.tar.gz".format(bazel_gazelle_version),
        ],
    )
