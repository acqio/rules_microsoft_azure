load("@bazel_skylib//lib:paths.bzl", "paths")

_AZ_TOOLCHAIN = "@rules_microsoft_azure//az/toolchain:toolchain_type"

def _check_enabled_extension(ctx, ext):
    exts = ctx.toolchains["@rules_microsoft_azure//az/toolchain:toolchain_type"].info.az_extensions_installed
    if not ext.strip() in exts:
        fail("This extension '{}' is not enabled.\n".format(ext) +
             "Configure the toolchain to enable this extension.")
    return True

def _substitutions_basename(n):
    s = paths.split_extension(n)
    return "%s.substituted.json" % (s[0])

common = struct(
    check_enabled_extension = _check_enabled_extension,
    resolve_tpl = Label("//az/private/common:resolve.sh.tpl"),
    substitutions_basename = _substitutions_basename,
)
