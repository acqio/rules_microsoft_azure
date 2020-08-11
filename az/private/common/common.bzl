load("//az:providers/providers.bzl", "AzToolchainInfo")

def _enable_rules(extensions, name):
    if name in extensions:
        return True
    return False

common = struct(
    enable_rules = _enable_rules,
    script_tpl = Label("//az/private/common:script.sh.tpl"),
)
