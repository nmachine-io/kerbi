# CLI Reference

## Root Commands

### $ `kerbi template [RELEASE] [PROJECT]`

Loads the project at `[PROJECT]`, and runs any mixers registered in `Kerbi::Globals.mixers`, making `[RELEASE]` available to all mixers.



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

Prints out all values compiled by Kerbi for the project in the current directory. Useful to preview the data that your mixers will be receiving. You cannot write the compiled values to state with this command.&#x20;

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





## Project Commands

### `$ kerbi project new [NAME] [options]`

Creates a boilerplate project called `[NAME]` in the current directory. While a Gemfile fill be generated, you do not technically need to run `bundle install` to get started, although you will need to at some point if your project becomes more serious.

<details>

<summary>Options</summary>

`--ruby-version [VER]` ruby version to use in Gemfile, e.g `--ruby-version 2.3`

`--verbose [BOOL]` prints out debug/info if true, e.g `--verbose true`

</details>

\`\`
