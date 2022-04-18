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

Prints out all information about the state named \[TAG] under `[RELEASE_NAME]`.&#x20;

adasdaasdsa

## Project Commands

### `kerbi project new [NAME] [options]`

Creates a boilerplate project called `[NAME]` in the current directory. While a Gemfile fill be generated, you do not technically need to run `bundle install` to get started, although you will need to at some point if your project becomes more serious.

<details>

<summary>Options</summary>

`--ruby-version [VER]` ruby version to use in Gemfile, e.g `--ruby-version 2.3`

`--verbose [BOOL]` prints out debug/info if true, e.g `--verbose true`

</details>

\`\`
