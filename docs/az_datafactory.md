<a name="az_datafactory"></a>
## az_datafactory

```python
az_datafactory(
    name,
    config,
    factory_name,
    resource,
    resource_group,
    resource_name,
    template
)
```

A rule for setting basic properties for other rules.

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <p><code>Name, required</code></p>
        <p>Unique name for this rule.</p>
      </td>
    </tr>
    <tr>
      <td><code>config</code></td>
      <td>
        <p><code>Label, required</code></p>
        <p>Label of <code>az_config</code> target.</p>
      </td>
    </tr>
    <tr>
      <td><code>factory_name</code></td>
      <td>
        <p><code>String, required</code></p>
        <p>The factory name.</p>
        <p>This field supports stamp variables.</p>
      </td>
    </tr>
    <tr>
      <td><code>resource</code></td>
      <td>
        <p><code>String, required</code></p>
        <p>The type of the object in the DataFactory.</p>
        <p>Supported values ​​are: <code>pipeline</code> and <code>trigger</code>.<p>
      </td>
    </tr>
    <tr>
      <td><code>resource_group</code></td>
      <td>
        <p><code>String, required</code></p>
        <p>Name of resource group.</p>
        <p>This field supports stamp variables.</p>
      </td>
    </tr>
    <tr>
      <td><code>resource_name</code></td>
      <td>
        <p><code>String, required</code></p>
        <p>The resource name (pipeline or trigger).</p>
      </td>
    </tr>
    <tr>
      <td><code>template</code></td>
      <td>
        <p><code>json file, required</code></p>
        <p>This template depends on the type of object in the DataFactory.</p>
        <p>
        I.e: If you define the <code>resource</code> as a <b>pipeline</b>, the template must contain the resource definition.
        If you define the <code>resource</code> as a <b>trigger</b>, the template must contain the propeties of the trigger.
        </p>
      </td>
    </tr>
  </tbody>
</table>

## Examples

```python
load("@rules_microsoft_azure//az:defs.bzl", "az_config", "az_datafactory")

genrule(
    name = "template",
    outs = ["template.json"],
    cmd = """
echo -e '{"properties": {"activities": [], "variables": {},"annotations": []}}' > \"$@\"
"""
)

az_config(
    name = "config",
    debug = True,
    subscription = "dev",
    verbose = True,
)

az_datafactory(
    name = "foo",
    config = ":config",
    factory_name = "foo-factory",
    resource = "pipeline",
    resource_group = "foo-factory-rg",
    resource_name = "foo",
    template = ":template",
)
```

## Usage

The `az_datafactory` rules expose a collection of actions. We will follow the `:foo`
target from the example above.

### Build
Build creates all the constituent elements and makes the model available like `{name}.substituted.json`.

```shell
bazel build :dev
```

NOTE: If the `resource` attribute is defined as a `pipeline`, the folder property will contain the destination bazel directory.

E.g:
```json
{
  "properties": {
    "folder": {
      "name": "bazel/<workspace_name>/path/to/target"
    }
  }
}
```

### Resolve

You can "resolve" your resource `template` by running:

```shell
bazel run :foo
```

The resolved `template` will be printed to `STDOUT`.

### Create or Update

Users can create or update objects by running:

```shell
bazel run :foo.create
```

This deploys the **resolved** template.

### Delete

Users can delete objects by running:

```shell
bazel run :foo.create
```

### Show

Users can get objects by running:

```shell
bazel run :foo.show
```

### Start

**NOTE**: Only available for the `trigger` resource.

Users can start a trigger by running:

```shell
bazel run :foo.start
```

### Stop

**NOTE**: Only available for the `trigger` resource.

Users can stop a trigger by running:

```shell
bazel run :foo.stop
```
