load("//az/private:rules/config.bzl", _config = "config")
load("//az/private:rules/datafactory/main.bzl", _datafactory = "datafactory")
load("//az/private:rules/storage/main.bzl", _storage = "storage")

az_config = _config
az_datafactory = _datafactory
az_storage = _storage
