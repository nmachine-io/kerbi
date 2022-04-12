# CLI Commands

### `kerbi template [RELEASE] [options]`

Loads the project at `[PROJECT]`, and runs any mixers registered in `Kerbi::Globals.mixers`, making `[RELEASE]` available to all mixers.

```
[RELEASE] for all intents and purposes, the namespace you want your resources to have
[PROJECT] the root path of the project. If running kerbi from the project root, use "."
```

<details>

<summary>Options</summary>

```
-o, --output-format [FORMAT] output format type, "yaml" or "json", defaults to "yaml", e.g -o json
-f, --value-file [FILE]      extra values file to be loaded (repeatable) e.g -f dev.yaml -f aws.yaml
    --read-state [ID/TYPE]   merge values from given state record into final values          
    --write-state [ID/TYPE]  write compiled values into given state record
    --namespace [NAME]       use this namespace in state operations 
    --set [ASSIGNMENT]       inline value assignment to be loaded (repeatable) e.g  --set x.y=z
```

</details>

``

### `kerbi values show [options]`

Prints out all values compiled by Kerbi for the project in the current directory. Useful to preview the data that your mixers will be receiving.

<details>

<summary>Options</summary>

```
-o, --output-format [FORMAT] output format type, "yaml" or "json", defaults to "yaml", e.g -o json
-f, --value-file [FILE]      extra values file to be loaded (repeatable) e.g -f dev.yaml -f aws.yaml
    --read-state [ID/TYPE]   merge values from given state record into final values          
    --write-state [ID/TYPE]  write compiled values into given state record
    --namespace [NAME]       use this namespace in state operations 
    --set [ASSIGNMENT]       inline value assignment to be loaded (repeatable) e.g  --set x.y=z
```

</details>

``

### `kerbi console [options]`

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
