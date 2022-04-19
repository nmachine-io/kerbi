# CLI Reference

## Overview

The Kerbi CLI should be available to you anywhere on the system provided you installed the Gem using `gem install`, as opposed adding it in a particular project's Gemfile.

The information below can be found by running `kerbi` in your command line:

```
Commands:
  kerbi config                                 # Command group for config actions (see $ kerbi config help)
  kerbi console                                # Opens an IRB console so you can play with your mixers
  kerbi help [COMMAND]                         # Describe available commands or one specific command
  kerbi project                                # Command group for project actions (see $ kerbi project help)
  kerbi release                                # Command group for release actions (see $ kerbi release help)
  kerbi state                                  # Command group for state actions (see $ kerbi state help)
  kerbi template [RELEASE_NAME] [PROJECT_URI]  # Templates to YAML/JSON, using [RELEASE_NAME] for state I/O
  kerbi values                                 # Command group for values actions (see $ kerbi values help)
  kerbi version                                # Print the kerbi gem's version.
```

## Root Commands

### $ `kerbi template [RELEASE_NAME] [PROJECT_URI]`

Template the project given by `[PROJECT_URI]`, where `[RELEASE_NAME]` is used for any state I/O (enabled with `--read-state` and `--write-state)`, and is made available to mixers as the instance variable `release_name`.&#x20;

{% tabs %}
{% tab title="Trivial" %}
```yaml
$ kerbi template hello .

apiVersion: v1
kind: Pod
metadata:
  name: hello-kerbi
  namespace: hello
  labels:
    app: hello-kerbi
spec:
  containers:
  - name: main
    image: nginx:alpine
```
{% endtab %}

{% tab title="Other project" %}
```yaml
$ ls
hello-kerbi

$ kerbi template hello hello-kerbi
apiVersion: v1
kind: Pod
metadata:
  name: hello-kerbi
  namespace: hello
  labels:
    app: hello-kerbi
spec:
  containers:
  - name: main
    image: nginx:alpine
```
{% endtab %}

{% tab title="With values" %}
```yaml
$ ls
hello-kerbi

apiVersion: v1
kind: Service
metadata:
  name: hello-kerbi
  namespace: hello
  annotations:
    author: person
  labels:
    app: hello-kerbi
spec:
  type: LoadBalancer
  selector:
    app: hello-kerbi
  ports:
  - port: 80
```
{% endtab %}

{% tab title="With state" %}
```yaml
kerbi template hello . \
    --set pod.image=fedora \ 
    --read-state @latest \ 
    --write-state @new-candidate

apiVersion: v1
kind: Pod
metadata:
  name: hello-kerbi
  namespace: hello
  annotations:
    author: person
  labels:
    app: hello-kerbi
spec:
  containers:
  - name: main
    image: fedora:alpine

```
{% endtab %}
{% endtabs %}

<details>

<summary>Options</summary>

```
Options:
  -o, [--output-format=OUTPUT-FORMAT]              # In what format resulting data should be printed
                                                   # Possible values: yaml, json, table
  -f, [--values-file=VALUES-FILE]                  # Merge all values read from this file. Multiple -f are allowed.
  --set, [--inline-value=INLINE-VALUE]             # Merge value from this assignment, e.g --set x.y=foo. Multiple --set are allowed.
      [--load-defaults], [--no-load-defaults]      # Whether or not to automatically load values.yaml.
                                                   # Default: true
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
```

</details>

### `$ kerbi console`

Starts an interactive console powered by [IRB](https://www.digitalocean.com/community/tutorials/how-to-use-irb-to-explore-ruby). The entire SDK is loaded into memory, plus your `kerbifile` and everything it requires. The following variables are available in the current binding:

* `values` - the same bundle of values available to `$ kerbi template`
* `default_values` the subset of values taken only from `values.yaml`

```
kerbi console --set pod.image=python

irb(kerbi):001:0> values
=> {:pod=>{:image=>"python"}, :service=>{:type=>"ClusterIP"}}
irb(kerbi):002:0> 

irb(kerbi):003:0> Kerbi::Globals.mixers
=> [HelloKerbi::Mixer]
```

<details>

<summary>Options</summary>

```
  -p, [--project-root=PROJECT-ROOT]     # Project root. An abs path, a rel path, or remote (/foo, foo, @foo/bar)
  -f, [--values-file=VALUES-FILE]       # Merge all values read from this file. Multiple -f are allowed.
  --set, [--inline-value=INLINE-VALUE]  # Merge value from this assignment, e.g --set x.y=foo. Multiple --set are allowed.
```

</details>

## Value Commands

### `$ kerbi values show`

Prints out all values compiled by Kerbi for the project in the current directory. Useful to preview the data that your mixers will be consuming.&#x20;

If you need to merge in state values, specify which release to use with `--release-name` along with the usual state parameters (found in `$ kerbi state`, `$ kerbi template`, etc...).

{% tabs %}
{% tab title="Trivial" %}
```yaml
$ kerbi values show

pod:
  image: nginx
service:
  type: ClusterIP
```
{% endtab %}

{% tab title="With state" %}
```
$ kerbi release init demo > /dev/null

$ kerbi template demo . \
    --set backend.image=node
    --write-state 1.0.0 \
    > /dev/null

$ kerbi values show \
    --release-name demo \ 
    --read-state 1.0.0

pod:
  image: node
service:
  type: ClusterIP
```
{% endtab %}
{% endtabs %}

<details>

<summary>Options</summary>

```
  -o, [--output-format=OUTPUT-FORMAT]              # In what format resulting data should be printed
                                                   # Possible values: yaml, json, table
  -p, [--project-root=PROJECT-ROOT]                # Project root. An abs path, a rel path, or remote (/foo, foo, @foo/bar)
  -f, [--values-file=VALUES-FILE]                  # Merge all values read from this file. Multiple -f are allowed.
  --set, [--inline-value=INLINE-VALUE]             # Merge value from this assignment, e.g --set x.y=foo. Multiple --set are allowed.
      [--load-defaults], [--no-load-defaults]      # Whether or not to automatically load values.yaml.
                                                   # Default: true
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
```

</details>

Starts an interactive console that lets you interact with code from your project, which is assumed to be in the current directory.

## Release Commands

### `$ kerbi release init [RELEASE_NAME]`

Provisions a new state tracking resource - either `ConfigMap` or `Secret` as per `--state-backend` - and prints out what it creates. This command does not fail if the resources already existed.

```
$ keri release init demo
namespaces/demo: Created
configmaps/demo/kerbi-demo-db: Created
```

<details>

<summary>Options</summary>

```
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
      [--verbose], [--no-verbose]                  # Run in verbose mode

```

</details>

### `$ kerbi release status [RELEASE_NAME]`

Attempts to connect to the persistent store that is tracking states for `[RELEASE_NAME`. &#x20;

```
$ kerbi release status demo
1. Create Kubernetes client: Success
2. List cluster namespaces: Success
3. Target namespace demo exists: Success
4. Resource demo/cm/kerbi-demo-db exists: Success
5. Data from resource is readable: Success
```

<details>

<summary>Options</summary>

```
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
      [--verbose], [--no-verbose]                  # Run in verbose mode

```

</details>

### `$ kerbi release list`

Prints out summary data about each release found in the cluster. Authentication to your cluster, as per `--k8s-auth-type` must be correct.

```
$ kerbi release list
NAME      BACKEND    NAMESPACE  RESOURCE           STATES  LATEST
antelope   ConfigMap  antelope   kerbi-antelope-db  2      1.0.0
zebra      ConfigMap  antelope   kerbi-zebra-db     1      short-cup
antelope   ConfigMap  default    kerbi-antelope-db  0
```

<details>

<summary>Options</summary>

```
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
      [--verbose], [--no-verbose]                  # Run in verbose mode

```

</details>

### `$ kerbi release delete [RELEASE_NAME]`

Deletes the resource responsible for tracking states for release `RELEASE_NAME`. You can skip the prompt with `--confirm`.&#x20;

```
$ kerbi release demo delete
Are you sure? Enter 'yes' to confirm or re-run with --confirm.
$ yes
Deleted configmaps/demo/kerbi-demo-db
```

<details>

<summary>Options</summary>

```
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
      [--confirm], [--no-confirm]                  # Skip any CLI confirmation prompts

```

</details>

## State Commands

### `$ kerbi state show [RELEASE_NAME] [TAG]`

Prints out summaries of all the states recorded under `[RELEASE_NAME]`.&#x20;

```
$ kerbi state list tuna
TAG              REVISION  MESSAGE  ASSIGNMENTS  OVERRIDES  CREATED_AT
0.2.2            0.2.0                        1          3  seconds ago
0.2.1            0.2.0                        1          5  seconds ago
keen-ethyl       0.1.0                        0          8  seconds ago
0.1.1            0.1.0                        1          2  minutes ago
```

<details>

<summary>Options</summary>

```
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
  -o, [--output-format=OUTPUT-FORMAT]              # In what format resulting data should be printed
                                                   # Possible values: yaml, json, table
```

</details>

### `$ kerbi state list [RELEASE_NAME]`

Prints out all information about the state named `[TAG]` under `[RELEASE_NAME]`.&#x20;

```
$ kerbi state show @latest
--------------------------------------------
 RELEASE_NAME     demo
--------------------------------------------
 TAG              0.0.1
--------------------------------------------
 MESSAGE
--------------------------------------------
 CREATED_AT       2022-04-13 10:32:55 +0100
--------------------------------------------
 VALUES           pod.image: ruby           
                  service.type: ClusterIP
--------------------------------------------
 DEFAULT_VALUES   pod.image: nginx          
                  service.type: ClusterIP
--------------------------------------------
 OVERRIDDEN_KEYS  pod
--------------------------------------------
```

<details>

<summary>Options</summary>

```
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
  -o, [--output-format=OUTPUT-FORMAT]              # In what format resulting data should be printed
                                                   # Possible values: yaml, json, table
```

</details>

### `$ kerbi state promote [RELEASE_NAME] [TAG]`

Remove the candidate flag from the state given by `[TAG]`'s name (`[cand]-`). This commands fails if the given state was not a candidate.

```
$ kerbi state promote hello @candidate
Updated state[banal-north].tag from [cand]-banal-north => banal-north

$ kerbi state promote hello @latest
Non-candidate states cannot be promoted
```

<details>

<summary>Options</summary>

```
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
```

</details>

### `$ kerbi state demote [RELEASE_NAME] [TAG]`

`Add` the candidate flag to a state's name (`[cand]-`). This commands fails if the given state was already a candidate.

```
$ kerbi state demote hello @latest
Updated state[[cand]-banal-north].tag from banal-north => [cand]-banal-north
```

<details>

<summary>Options</summary>

```
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
```

</details>

### `$ kerbi state retag [R_NAME] [OLD_TAG] [NEW_TAG]`

Update a state record's tag.

```
$ kerbi state retag hello @candidate 1.2.3
Updated state[1.2.3].tag from [cand]-burly-robin => 1.2.3
```

<details>

<summary>Options</summary>

```
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
```

</details>

### `$ kerbi state prune-candidates [RELEASE_NAME]`

Deletes all state records under `[RELEASE_NAME]` that are flagged as candidates.

```
$ kerbi state list hello
TAG                REVISION MESSAGE ASSIGNMENTS OVERRIDES CREATED_AT
1.2.3                               2           1         a minute ago
[cand]-banal-curry                  2           0         6 minutes ago
[cand]-banal-north                  2           0         19 minutes ago

$ kerbi state prune-candidates hello
Pruned 2 state entries

$ kerbi state list hello
TAG                REVISION MESSAGE ASSIGNMENTS OVERRIDES CREATED_AT
1.2.3                               2           1         a minute ago
```

<details>

<summary>Options</summary>

```
  -n, [--namespace=NAMESPACE]                      # Use this Kubernetes namespace instead of [RELEASE_NAME] for state I/O.
      [--state-backend=STATE-BACKEND]              # Type of persistent store to read/write this release's state.
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from state with this tag.
      [--write-state=WRITE-STATE]                  # Write compiled values into new or existing state recordwith this tag.
      [--k8s-auth-type=K8S-AUTH-TYPE]              # Kubernetes cluster authentication type. Uses kube-config if unspecified.
                                                   # Possible values: kube-config, in-cluster, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # Path to your kube-config file. Uses ~/.kube/config if unspecified.
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # Context to use in your kube config. Uses current context if unspecified.
```

</details>

## Config Commands

### `$ kerbi config show`

Prints the final compiled configuration kerbi will use.&#x20;

{% hint style="warning" %}
**Not the exact contents of the config file**

This command shows what Kerbi sees after it has loaded your config file **and** processed it, e.g sanitized it with fallback values. If you need to read your config file, just read it normally: `cat ~/.kerbi/config`.
{% endhint %}

```yaml
$ kerbi config show
load-defaults: true
inline-value: []
values-file: []
output-format: yaml
state-backend: configmap
k8s-auth-type: kube-config
```

### `$ kerbi config set [KEY] [VALUE]`

Updates one attribute in your global config file. This command will fail if you attempt to set an attribute not supported in the config file.&#x20;

```
$ kerbi config set output-format json
```

### `$ kerbi config reset`

Deletes your global configuration file and creates an empty one.

```
$ kerbi config reset
Config reset
See /home/xavier/.kerbi/config.json
```

## Project Commands

### `$ kerbi project new [NAME]`

Creates a boilerplate project called `[NAME]` in the current directory. While a Gemfile fill be generated, you do not technically need to run `bundle install` to get started, although you will need to at some point if your project becomes more serious.

```
$ kerbi project new rhino
Created project at /home/xavier/rhino
Created file rhino/Gemfile
Created file rhino/kerbifile.rb
Created file rhino/values.yaml
```

<details>

<summary>Option</summary>

```
  [--ruby-version=RUBY-VERSION]  # Ruby version semver for autogenerated Gemfile.
  [--verbose], [--no-verbose]    # Run in verbose mode
```

</details>
