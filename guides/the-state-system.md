# Releases & States

Kerbi's state management system lets you store the values it computes as part of certain commands (`template` and `values)`, and then retrieve those values again. Kerbi uses a `ConfigMap`, `Secret`, or database in your cluster to store the data.

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
$ kerbi template foo \
    --set pod.image=v2 \
    --read-state @latest \
    --write-state @new-candidate \
    > manifest.yaml

$ kubectl apply --dry-run=server -f manifest.yaml \
  && kerbi state promote @candidate
  && kubectl apply -f manifest.yaml
```

Running `kubectl apply` with `--dry=run-server` will yield a status code of `"0"` if all resources were accepted, and `"1"` otherwise.  Therefore, the statement that comes after the `&&` only gets evaluated if Kubernetes accepted all our resources -  what we wanted.

## What is a State?

A state is a record that stores the values (aka variables) that were computed during a `$ kerbi template` operation, provided a `--write state [TAG]` flag is passed.&#x20;

State records have the following attributes:

* `tag` - its unique name, which can be anything
* `message` any human readable note, or perhaps a git commit id
* `values` the final values computed by `template` or `values show`
* `default_values` the final **default** values computed by `template` or `values show`
* `created_at` an ISO8601 timestamp

You can easily inspect any state with the CLI:

{% tabs %}
{% tab title="Table output" %}
```
$ kerbi state show antelope @latest

--------------------------------------------
 RELEASE          zebra
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
$ kerbi state show demo @latest -o json

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

## What is a Release?

A release is a collection of states. A release also means "one instance of the app".&#x20;

### Name, Namespace, and Resource Name

In a world where a Kubernetes namespace was a reliable boundary for an application's perimeter, we (and probably Helm) would just use namespaces. But this is unfortunately not the case.

A release is identified by its name and its namespace. Unless you pass `--namespace [NAME]`, its namespace will automatically be set to its name. Let's build an intuition:

{% tabs %}
{% tab title="Kerbi" %}
```
$ kerbi release init antelope
namespaces/antelope: Created
configmaps/antelope/kerbi-antelope-db: Created

$ kerbi release init zebra --namespace antelope
namespaces/antelope: Already existed
configmaps/antelope/kerbi-zebra-db: Created

$ kerbi release init antelope --namespace default
namespaces/default: Already existed
configmaps/default/kerbi-antelope-db: Created
```
{% endtab %}

{% tab title="Kubectl" %}
```
$ kubectl get configmap --all-namespaces
NAMESPACE            NAME                                 DATA   AGE
antelope             kerbi-antelope-db                    1      4m14s
antelope             kerbi-zebra-db                       1      4m14s
default              kerbi-antelope-db                    1      3m3s
```
{% endtab %}
{% endtabs %}

### Referring to Releases

When you run a command like `$ kerbi template [RELEASE_NAME]`, Kerbi will look for a `ConfigMap` called `kerbi-[RELEASE_NAME]-db` in the namespace `[RELEASE_NAME]`.&#x20;

If instead you run it with `--namespace` e.g `$ kerbi template [RELEASE_NAME] --namespace [NAMESPACE]` then it will look for the `ConfigMap` in the namespace `[NAMESPACE]`.

Remember you can easily figure out what's where with:

```
$ kerbi release list
NAME      BACKEND    NAMESPACE  RESOURCE           STATES  LATEST
antelope   ConfigMap  antelope   kerbi-antelope-db  0
zebra      ConfigMap  antelope   kerbi-zebra-db     0
antelope   ConfigMap  default    kerbi-antelope-db  0
```

### Subtle Difference with Helm

Release names and namespaces are confusing. If you're used to Helm, it's important to highlight the difference. Illustrative <mark style="color:yellow;">**pseudocode**</mark>:

```
# HOW KERBI DOES IT
release_name = read('release_name')
namespace = release_name || read('namespace')

# HOW HELM DOES IT
release_name = read('release_name')
namespace = read(namespace) || 'default'
```

## Configuration

### **State management backends**

Kerbi can store the compiled values data in a `ConfigMap`, a `Secret`, or an arbitrary database. **** You can set this behavior either with a flag e.g `--backend ConfigMap` or in the global Kerbi config e.g `$ kerbi config set state-backend: Secret`.&#x20;

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

## State Tag Substitutions

We can feed the CLI special expressions instead of literals tag. When Kerbi encounters a special keyword, formatted as `@<keyword>`, it will attempt to resolve it to a literal tag name. Depending on the keyword, the resolved tag may or may not refer to an existing state tag.&#x20;

### The `@latest` keyword

Resolves to the tag of the **newest **_**non**_**-candidate** state (as given by `created_at`). Behavior is the same during read and write operations.&#x20;

Example: `$ kerbi state show zebra @latest`

### The `@candidate` keyword

Resolves to the tag of the **newest candidate** state (as given by `created_at`). Behavior is the same during read and write operations.&#x20;

Example: `$ kerbi state retag zebra @candidate 1.2.3`

### The `@new-candidate` keyword

Resolves to a random, free (not yet taken by existing states) tag **with a candidate status prefix**. Only works for write operations.&#x20;

Example: `$ kerbi values show -f v2.yaml --write-state @new-candidate`. The name of the new state in this case resolved to `"[cand]-purple-purse"`

### The `@random` keyword

Resolves to a random, free (not yet taken by existing states) tag **without a candidate status prefix**. Only works for write operations.&#x20;

Example: `$ kerbi values show -f v2.yaml --write-state @random`. The name of the new state in this case resolved to `"spiky-goose"`

## State Attributes

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

