# CLI Reference

## Root Commands

### $ `kerbi template [RELEASE] [options]`

Loads the project at `[PROJECT]`, and runs any mixers registered in `Kerbi::Globals.mixers`, making `[RELEASE]` available to all mixers.

```
[RELEASE] for all intents and purposes, the namespace you want your resources to have
```

```
  -p, [--project-root=PROJECT-ROOT]                # Project root. An abs path, a rel path, or remote (/foo, foo, @foo/bar)
  -o, [--output-format=OUTPUT-FORMAT]              # Specify YAML, JSON, or table
                                                   # Possible values: yaml, json, table
  -f, [--values-file=VALUES-FILE]                  # Name of a values file to be loaded.
  --set, [--inline-value=INLINE-VALUE]             # An inline variable assignment, e.g --set x.y=foo --set x.z=bar
      [--load-defaults], [--no-load-defaults]      # Automatically load values.yaml. Defaults to true.
                                                   # Default: true
  -n, [--namespace=NAMESPACE]                      # for state operations, tell kerbi that the state
               configmap/secret is in this namespace
      [--state-backend=STATE-BACKEND]              # Persistent store to keep track of applied values (configmap, secret)
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from given state record into final values.
      [--write-state=WRITE-STATE]                  # write compiled values into given state record
      [--auth-type=AUTH-TYPE]                      # Strategy for connecting to target cluster (defaults to kube-config)
                                                   # Possible values: kube-config, in-cluster, basic, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # path to your kube-config file, defaults to ~/.kube/config
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # context to use in your kube config,
defaults to $(kubectl config current-context)

```

<details>

<summary>Options</summary>



</details>

## Values Commands

### `$ kerbi values show [options]`

Prints out all values compiled by Kerbi for the project in the current directory. Useful to preview the data that your mixers will be receiving.

<details>

<summary>Options</summary>

```

  -p, [--project-root=PROJECT-ROOT]                # Project root. An abs path, a rel path, or remote (/foo, foo, @foo/bar)
  -o, [--output-format=OUTPUT-FORMAT]              # Specify YAML, JSON, or table
                                                   # Possible values: yaml, json, table
  -f, [--values-file=VALUES-FILE]                  # Name of a values file to be loaded.
  --set, [--inline-value=INLINE-VALUE]             # An inline variable assignment, e.g --set x.y=foo --set x.z=bar
      [--load-defaults], [--no-load-defaults]      # Automatically load values.yaml. Defaults to true.
                                                   # Default: true
  -n, [--namespace=NAMESPACE]                      # for state operations, tell kerbi that the state
               configmap/secret is in this namespace
      [--state-backend=STATE-BACKEND]              # Persistent store to keep track of applied values (configmap, secret)
                                                   # Possible values: configmap, secret
      [--read-state=READ-STATE]                    # Merge values from given state record into final values.
      [--write-state=WRITE-STATE]                  # write compiled values into given state record
      [--auth-type=AUTH-TYPE]                      # Strategy for connecting to target cluster (defaults to kube-config)
                                                   # Possible values: kube-config, in-cluster, basic, token
      [--kube-config-path=KUBE-CONFIG-PATH]        # path to your kube-config file, defaults to ~/.kube/config
      [--kube-config-context=KUBE-CONFIG-CONTEXT]  # context to use in your kube config,
defaults to $(kubectl config current-context)

```

</details>

``

### `$ kerbi console [options]`

Starts an interactive console that lets you interact with code from your project, which is assumed to be in the current directory.

<details>

<summary>Options</summary>

`-o [FORMAT]` output format type, `"yaml"` or `"json"`, defaults to `"yaml"`

`-f [FILE]` extra values file to be loaded (repeatable) e.g `-f dev.yaml -f aws.yaml`

`--set [ASSIGNMENT]` inline value assignment (repeatable) e.g  `--set x.y=z`

</details>

``

### `kerbi project new [NAME] [options]`

Creates a boilerplate project called `[NAME]` in the current directory. While a Gemfile fill be generated, you do not technically need to run `bundle install` to get started, although you will need to at some point if your project becomes more serious.

<details>

<summary>Options</summary>

`--ruby-version [VER]` ruby version to use in Gemfile, e.g `--ruby-version 2.3`

`--verbose [BOOL]` prints out debug/info if true, e.g `--verbose true`

</details>

``