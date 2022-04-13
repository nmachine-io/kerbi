# State Management

Kerbi's state system lets you store the values it computes as part of certain commands (`template` and `values)`, and then retrieve those values again. Kerbi uses a `ConfigMap`, `Secret`, or database in your cluster to store the data.

For a practical example state management, see the [Walkthrough](simple-kubernetes-example.md#6.-writing-state).&#x20;

## Kubernetes Workflow

### Conceptual Workflow

Your goal as a developer using variable-based templating in a modern CD pipeline should be to achieve the following workflow:

{% tabs %}
{% tab title="In English" %}
1. **Template** a new manifest using new values (e.g a new image name) plus the old values
2. **Try applying** that new manifest to the Kubernetes cluster
3. **If the apply worked**:
   1. **Store the values** you just used to generate this manifest for next time
4. Otherwise:
   1. **Stop everything**, ping devs, etc...&#x20;
{% endtab %}

{% tab title="In Pseudo code" %}
{% code title="PSEUDO CODE" %}
```ruby
manifest, compiled_values = kerbi.template(
  file_values: read_file("production.yaml"),
  inline_values: parse("pod.image=v2"),
  prev_state_values: find_last_applied_values() || {}
)

if kubernetes.apply(manifest) == 'success'
    kerbi.create_state(
        tag: "1.0.2", 
        values: compiled_values
    )
end
```
{% endcode %}
{% endtab %}
{% endtabs %}

### Helm Workflow

Helm does this for you in one line with:

```
$ helm install foo . \
    --set pod.image=v2
```

This is great, but there are some downsides, namely that you are delegating arguably the most critical command Kubernetes in all of Kubernetes - `kubectl apply` - to another tool.

### Kerbi Workflow

Kerbi, on the other hand, is designed to never run critical operations like `kubectl apply` on your behalf. So with Kerbi, you can implement this workflow as follows:

```
$ kerbi template \
    --set pod.image=v2 \
    --read-state @latest \
    --write-state @new-candidate \
    > manifest.yaml

$ kubectl apply --dry-run=server -f manifest.yaml \
  && kerbi state promote @candidate
```

Running `kubectl apply` with `--dry=run-server` will yield a status code of `"0"` if all resources were accepted, and `"1"` otherwise.  Therefore, the statement that comes after the `&&` only gets evaluated if Kubernetes accepted all our resources -  what we wanted.

## Configuration

### &#x20;**State management backends.**

Kerbi can store the compiled values data in a `ConfigMap`, a `Secret`, or an arbitrary database. **** You can set this behavior either with a flag e.g `--backend ConfigMap` or in the global Kerbi config e.g `$ kerbi config set state-backend: Secret`.

If you use a `ConfigMap` or `Secret`, you'll need to give Kerbi access your cluster. There

## Candidate Status

## Edge Case Behavior

&#x20;

## Tag Substitutions

We can feed the CLI special expression instead of literals tag. When Kerbi encounters a special keyword, formatted as `@<keyword>`, it will attempt to resolve it to a literal tag name. Depending on the keyword, the resolved tag may or may not refer to an existing state tag.&#x20;

### The `@latest` keyword

Resolves to the tag of the **newest **_**non**_**-candidate** state (as given by `created_at`). Behavior is the same during read and write operations.&#x20;

Example: `$ kerbi state show @latest`

### The `@candidate` keyword

Resolves to the tag of the **newest candidate** state (as given by `created_at`). Behavior is the same during read and write operations.&#x20;

Example: `$ kerbi state retag @candidate @candidate-two`

### The `@new-candidate` keyword

Resolves to a random, free (not yet taken by existing states) tag **with a candidate status prefix**. Only works for write operations.&#x20;

Example: `$ kerbi values show -f v2.yaml --write-state @new-candidate`. The name of the new state in this case resolved to `"[cand]-purple-purse"`

### The `@random` keyword

Resolves to a random, free (not yet taken by existing states) tag **without a candidate status prefix**. Only works for write operations.&#x20;

Example: `$ kerbi values show -f v2.yaml --write-state @random`. The name of the new state in this case resolved to `"spiky-goose"`

