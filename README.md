# Kerbi: Kubernetes Templating and State Management

[![codecov](https://codecov.io/gh/nectar-cs/kerbi/branch/master/graph/badge.svg)](https://codecov.io/gh/nectar-cs/kerbi)
[![Gem Version](https://badge.fury.io/rb/kerbi.svg)](https://badge.fury.io/rb/kerbi)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Kerbi is a Kubernetes tool most similar to [Helm](https://helm.sh/), with the following key differences:
- Templating: also variable-based, but aspires to be more powerful, flexible, and delightful
- State management: aspires to be less invasive, more deliberate, explict, and transparent
- Packaging: a central registry for managing your own chart's revisions is in the works

[Documentation.](https://xavier-9.gitbook.io/untitled/walkthroughs/getting-started)

## Getting Started

Install the `kerbi` RubyGem globally: 

```bash
$ gem install kerbi
```

Now use the new `kerbi` executable to initialize a project and install the dependencies:

```yaml
$ kerbi project new hello-kerbi
$ cd hello-kerbi
```

Voila. You can now generate templates and manage state:

```yaml
$ kerbi template demo . --set message=special
text: special demo message
```

**[Documentation.](https://xavier-9.gitbook.io/untitled/walkthroughs/getting-started)**

## Features

### 💲 Variable based like Helm

Like Helm, your templating logic depends on key-value pairs (aka variables) you pass in at runtime. 
Your have a baseline `values.yaml` file and then three possible sources of extra variables:
- override files, e.g`-f production.yaml`, 
- inline assignments, e.g `--set backend.ingress.enabled=false`,
- previously committed values, e.g `--read-state @latest` via state management (covered later)

```yaml
$ kerbi values show -f production.yaml --set backend.image=centos
pod:
  image: centos
service:
  type: NodePort
```




### 📜 Basic Templating with YAML embedded with Ruby

Kerbi lets you do your basic templating with Ruby embedded YAML (`ERB`), 
keeping your template files readable to all and singularly focused, 
while your more complex logic goes in Mixers shown in the following section.

**`deployment.yaml.erb`**
```yaml
apiVersion: appsV1
kind: Deployment
metadata:
  name: <%= MyApp::Backend::Consts::NAME %>
  namespace: <%= release_name %>
  labels: <%= embed(common_labels) %>
spec: 
  replicas: <%= values[:deployment][:replicas] %>
  template:
    spec:
      containers: <%= embed_array(
                        file('containers') + 
                        mixer(Hooli::Traefik::ContainerMixer))
                   ) %>
```




### 🚦 Powerful Higher Order Templating Model

Mixers give you control and organization. Inside your `Mixer` subclasses, 
you can explicitly load up your lower level template files (like `deployment.yaml.erb` above), other mixers,
entire directories, or even raw Helm charts. Loader functions like `file()` and `dir()` return a 
sanitized `Array<Hash>`, making it easy to filter, patch, or modify output.

**`backend/mixer.rb`**
```ruby
class MyApp::Backend::Mixer < Kerbi::Mixer
  include MyApp::Common::KubernetesLabels

  def mix
    push file("deployment")
    push file("pvc") if persistence_enabled?
    push(mixer(ServiceMixer) + file("ingress"))
    
    patched_with file("annotations") do
      push helm_chart("my-legacy/helm-chart")
      push dir("./../rbac", only: [{kind: 'ClusterRole.*'}])
    end
  end 
  
  def persistence_enabled?
    values.dig(:database, :enabled).present?
  end
end
```



### 📀 Explicit & Non Invasive State Management

Kerbi lets you persist and retreive the bundles of the variables you generate your manifests 
with to a `ConfigMap` or `Secret`. Unlike Helm, which couples state with a heavy 
handed concept of "releases" (that annotates your resources, kubectl's for you, etc...), Kerbi opts 
for a simple, deliberate, and non-invasive API: `--read-state` and `--write-state`.

`our-cd-pipeline.sh`
```
$ kerbi release init tuna

$ kerbi template tuna . \
        --set some.deployment.image=v2 \
        --read-state @latest \
        --write-state @new-candidate \
        > manifest.yaml

$ kubectl apply --dry-run=server -f manifest.yaml \
  && kerbi state retag @candidate @latest+0.0.1 \
  && kubectl apply -f manifest.yaml  
```

List states for the `tuna` release:
```
$ kerbi state list tuna
TAG              REVISION  MESSAGE  ASSIGNMENTS  OVERRIDES  CREATED_AT
0.2.2            0.2.0              1            3          seconds ago
0.2.1            0.2.0              1            5          seconds ago
keen-ethyl       0.1.0              0            8          seconds ago
0.1.1            0.1.0              1            2          minutes ago
```

List all releases:
```
$ kerbi release list
NAME  BACKEND    NAMESPACE  RESOURCE       STATES  LATEST
bass  ConfigMap  bass       kerbi-bass-db  4       0.0.2
tuna  ConfigMap  default    kerbi-tuna-db  2       baser-mitre
tuna  ConfigMap  tuna       kerbi-tuna-db  1       0.0.1
```


### ⌨️ Interactive Console

My favorite thing about CDK8s is that it feels like a normal computer program. 
Kerbi takes that one step further by letting you run your code in interactive mode (via IRB), 
making it easy to play with your code or the Kerbi lib.

```ruby
$ kerbi console --set backend.database.enabled=true

irb(kerbi):001:0> values
=> {:backend=>{:database=>{:enabled=>"true"}}}

irb(kerbi):003:0> MyApp::Backend::Mixer.new(values).run
=> [{:apiVersion=>"appsV1", :kind=>"Deployment", :metadata=>{:name=>"backend", :namespace=>"default"}, :spec=>"foo"}]

irb(kerbi):003:0> Kerbi::ConfigFile.read
=> {'k8es-auth-type': 'kube-config'}


```

## Getting Involved

[CONTRIBUTING.md](https://github.com/nmachine-io/kerbi/blob/master/CONTRIBUTING.md)

Email: xavier@nmachine.io

Discord: https://discord.gg/ntAs6TaD

# Running the Examples

Have a look at the [examples](https://github.com/nmachine-io/kerbi/tree/master/examples) directory. 
If you want to go a step further and run them from source, clone the project, `cd` into the example you 
want. For instance:

```bash
$ cd examples/hello-kerbi
$ kerbi template default .
```
