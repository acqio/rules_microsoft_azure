load("//az:providers/providers.bzl", "AzToolchainInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

BAZEL_PATH = "bazel"

def _enable_rules(extensions, name):
    if name in extensions:
        return True
    return False

def _check_enabled_extension(extensions_installed, extension):
    if not _enable_rules(extensions_installed, extension):
        fail("This extension '{}' is not enabled.\n".format(extension) +
             "Configure the toolchain to enable this extension.")
    return True

def _pipeline_folder(path):
    return paths.normalize(paths.join(BAZEL_PATH, path))

def _template_file_name(file_name):
    split = paths.split_extension(file_name)
    return "%s.substituted.json" % (split[0])

common = struct(
    check_enabled_extension = _check_enabled_extension,
    enable_rules = _enable_rules,
    pipeline_folder = _pipeline_folder,
    resolve_tpl = Label("//az/private/common:resolve.sh.tpl"),
    script_tpl = Label("//az/private/common:script.sh.tpl"),
    template_file_name = _template_file_name,
)
