# State Management

Kerbi's state system lets you store the values it computes as part of certain commands (`template` and `values)`, and then retrieve those values again. Kerbi uses a `ConfigMap`, `Secret`, or database in your cluster to store the data.

To build an intuitive understanding of state management, see the [Walkthrough](simple-kubernetes-example.md#6.-writing-state).&#x20;

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

### **State management backends**

Kerbi can store the compiled values data in a `ConfigMap`, a `Secret`, or an arbitrary database. **** You can set this behavior either with a flag e.g `--backend ConfigMap` or in the global Kerbi config e.g `$ kerbi config set state-backend: Secret`.

{% hint style="warning" %}
**Only `ConfigMap` currently works**

Secret and database are not yet finished.
{% endhint %}

If you use a `ConfigMap` or `Secret`, you'll need to give Kerbi **access your cluster**. The examples below show the three different ways to do that.&#x20;

{% tabs %}
{% tab title="KubeConfig Auth" %}
To use this auth mode:

```
$ kerbi config set k8s-auth-type kube-config
```



If you have a `~/.kube/config.yaml` on your machine, then this should work without any further configuration. The following settings are available:



```
$ kerbi config set kube-config-path /path/to/your/kube/config
$ kerbi config set kube-config-context <e.g gke-stagging-cluster>
```
{% endtab %}

{% tab title="Access Token Auth" %}
To use this auth mode:

```
$ kerbi config set k8s-auth-type access-token
```

\
Probably what you want in CI/CD if you have a [ServiceAccount](the-state-system.md#kubernetes-workflow) and a remote cluster. You need to supply an access token, a.k.a bearer token:



```
$ kerbi config set k8s-access-token <token>
```
{% endtab %}

{% tab title="In-Cluster Auth" %}
To use this auth mode:

```
$ kerbi config set k8s-auth-type in-cluster
```



For running Kerbi inside a pod. You don't need to supply any additional auth credentials; Kerbi will authenticate using the following values:



{% code title="pseudocode" %}
```
token_path = '/var/run/secrets/kubernetes.io/serviceaccount/token'
ca_crt_path = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
```
{% endcode %}
{% endtab %}
{% endtabs %}

Note that each configuration above can also be passed as a flag in any state touching operation, e.g `$ kerbi template --k8s-auth-type in-cluster`.

## Tag Substitutions

We can feed the CLI special expressions instead of literals tag. When Kerbi encounters a special keyword, formatted as `@<keyword>`, it will attempt to resolve it to a literal tag name. Depending on the keyword, the resolved tag may or may not refer to an existing state tag.&#x20;

### The `@latest` keyword

Resolves to the tag of the **newest **_**non**_**-candidate** state (as given by `created_at`). Behavior is the same during read and write operations.&#x20;

Example: `$ kerbi state show @latest`

### The `@candidate` keyword

Resolves to the tag of the **newest candidate** state (as given by `created_at`). Behavior is the same during read and write operations.&#x20;

Example: `$ kerbi state retag @candidate 1.2.3`

### The `@new-candidate` keyword

Resolves to a random, free (not yet taken by existing states) tag **with a candidate status prefix**. Only works for write operations.&#x20;

Example: `$ kerbi values show -f v2.yaml --write-state @new-candidate`. The name of the new state in this case resolved to `"[cand]-purple-purse"`

### The `@random` keyword

Resolves to a random, free (not yet taken by existing states) tag **without a candidate status prefix**. Only works for write operations.&#x20;

Example: `$ kerbi values show -f v2.yaml --write-state @random`. The name of the new state in this case resolved to `"spiky-goose"`

## State Attributes

What attributes make up a state record? Kerbi strives to be lightweight, and thus only stores a small amount of data for each state record, namely:

* `tag` - its unique name, which can be anything
* `message` any human readable note, or perhaps a git commit id
* `values` the final values computed by `template` or `values show`
* `default_values` the final **default** values computed by `template` or `values show`
* `created_at` an ISO8601 timestamp

You can easily inspect any state with the CLI:

{% tabs %}
{% tab title="Table output" %}
```
$ kerbi state show @latest

 --------------------------------------------
 TAG              1.0.0
--------------------------------------------
 MESSAGE
--------------------------------------------
 CREATED_AT       2022-04-12 14:43:24 +0100
--------------------------------------------
 VALUES           pod.image: centos          
                  service.type: ClusterIP
--------------------------------------------
 DEFAULT_VALUES   pod.image: nginx          
                  service.type: ClusterIP
--------------------------------------------
 OVERRIDDEN_KEYS  pod.image
--------------------------------------------
```
{% endtab %}

{% tab title="JSON output" %}
```json
$ kerbi state show @latest -o json

{
  "tag": "0.0.1",
  "message": null,
  "created_at": "2022-04-13 10:32:55 +0100",
  "values": {
    "pod": {
      "image": "centos"
    },
    "service": {
      "type": "ClusterIP"
    }
  },
  "default_values": {
    "pod": {
      "image": "nginx"
    },
    "service": {
      "type": "ClusterIP"
    }
  },
  "overridden_keys": [
    "pod.image"
  ]
}
```
{% endtab %}
{% endtabs %}

## Candidate Status

States have a "candidate" flag to make it possible to implement the conceptual workflow described in the first section. In short, you want a state to be in candidate mode until you know it has been successfully applied to the cluster.&#x20;

### Designation

To make Kerbi as simple as possible, there is no special attribute to designate candidacy, only a special prefix `[cand]-`. So any state that begins with `[cand]-` is treated as a candidate. Conversely, if you want to promote a state to non-candidate _and_ rename it in one go, just:

```
$ kerbi state retag @candidate <a-new-name>
```

### Creation

Because the

### Promoting and Pruning

To promote a state and keep its name, run:

```
$ kerbi state promote @candidate
```

You can also delete all candidate states with one command:

```
$ kerbi state prune-candidates 
```

