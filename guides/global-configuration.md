---
description: Save time by making some configurations global.
---

# Global Configuration

Like many tools, Kerbi creates a small config file in your home directory where it can read/write configurations you want applied for every command.

## The Config File

The config file itself is located at `$HOME/.kerbi/config.json`. If it does not exist, Kerbi will create it when it needs it. You can delete it without crashing Kerbi. To output its exact location, run:&#x20;

```
$ kerbi config location
/home/batman/.kerbi/config.json
```

## Using the CLI

The two main things you will want to do are set configurations and view the compiled configuration. To do these, read up on the [Config Command Group](cli-commands.md#config-commands). In summary:

Viewing compiled configuration:

```yaml
$ kerbi config show
load-defaults: true
output-format: yaml
state-backend: configmap
k8s-auth-type: kube-config
kube-config-path: null
kube-config-path: null
```

Updating attributes:

```
$ kerbi config set output-format json
```

## Legal Attributes

The attributes you can configure globally are a subset of the flag-style options available to commands:

```
output-format          # In what format resulting data should be printed                                                   # Possible values: yaml, json, table
load-defaults          # Whether or not to automatically load values.yaml.
state-backend          # Type of persistent store to read/write this release's state.                                                   # Possible values: configmap, secret
k8s-auth-type          # Kubernetes cluster authentication type. Uses kube-config if unspecified.                                                   # Possible values: kube-config, in-cluster, token
kube-config-path       # Path to your kube-config file. Uses ~/.kube/config if unspecified.
kube-config-context    # Context to use in your kube config. Uses current context if unspecified.
```
