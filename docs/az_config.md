<a name="az_config"></a>
## az_config

```python
az_config(
    name,
    debug,
    subscription,
    verbose
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
      <td><code>debug</code></td>
      <td>
        <p><code>Boolean, optional, default is False</code></p>
        <p>Increase logging verbosity to show all debug logs.</b></p>
      </td>
    </tr>
    <tr>
      <td><code>subscription</code></td>
      <td>
        <p><code>String, required</code></p>
        <p>Name or ID of subscription.</p>
        <p>Obtain this information by running: <code>bazel run @az//:cli -- account list</code></p>
      </td>
    </tr>
    <tr>
      <td><code>verbose</code></td>
      <td>
        <p><code>Boolean, optional, default is False</code></p>
        <p>Increase logging verbosity. Use --debug for full debug logs.</b></p>
      </td>
    </tr>
  </tbody>
</table>

## Examples

```python
load("@rules_microsoft_azure//az:def.bzl", "az_config")

az_config(
    name = "config",
    debug = True,
    subscription = "dev",
    verbose = True,
)
```
