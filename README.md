# Kerbi: K8s State & Templating Engine

[![codecov](https://codecov.io/gh/nectar-cs/kerbi/branch/master/graph/badge.svg)](https://codecov.io/gh/nectar-cs/kerbi)
[![Gem Version](https://badge.fury.io/rb/kerbi.svg)](https://badge.fury.io/rb/kerbi)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Kerbi is a Kubernetes tool most similar to [Helm](https://helm.sh/). It does two things:

**1. Variable-based manifest templating** based on ERB (YAML/JSON embedded Ruby)

**2. State management** for the applied variables, reading/writing to a `ConfigMap`, `Secret`, or database

## Getting Started

**[Complete guide and more.](https://xavier-9.gitbook.io/untitled/walkthroughs/getting-started)**

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
$ kerbi template demo --set message=special
text: special demo message
```

## Drawing from Helm, Kapitan, and CDK8s

### 💲 Variable Based like Helm

Like with Helm, your control knobs are key-value pairs that you pass in at runtime,
which your templating logic uses to interpolate the final manifest. Your have your 
baseline `values.yaml` file, override files passed via CLI, e.g
`-f production.yaml`, inline assignments, e.g `--set backend.ingress.enabled=false`,
and previously committed values, e.g `--read-state @latest`:

```yaml
$ kerbi values show \
        -f production.yaml \
        --set backend.image=centos \
        --read-state 1.2.3
pod:
  image: centos
service:
  type: NodePort
```

### 📜 Popular Templating Language: Ruby in YAML

Helm's Go-in-YAML might be awkward, but makes the right choice of sticking to Kubernetes' lingua franca - YAML.
Kapitan and CDK8S offer a better DX, but only if you 1) know their dialects or object models well,
and 2) actually need hardcore templating everywhere in your project.

**`deployment.yaml.erb`**
```yaml
apiVersion: appsV1
kind: Deployment
metadata:
  name: <% MyApp::Backend::Consts::NAME %>
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
In Kerbi, you do most of your templating in YAML embedded with Ruby (`ERB`). As shown two sections
beneath, you can seamlessly mix between two extremes: fully programmatic and fully YAML.


Zero innovation here because Helm does it perfectly.

### 📀 Explicit & Non-Invasive State Management

Kerbi lets you persist and retreive the bundles of the variables you generate your manifests 
with to a `ConfigMap` or `Secret`. Unlike Helm, which couples state with a heavy 
handed concept of "releases" (that annotates your resources, kubectl's for you, etc...), Kerbi opts 
for a simple, deliberate, and non-invasive API: `--read-state` and `--write-state`.

1. Setup with `init [NAMESPACE]` 
```javascript
$ kerbi state init demo
namespaces/demo: Created
demo/configmaps/kerbi-state-tracker: Created

$ kerbi state list
 TAG                 MESSAGE  ASSIGNMENTS  OVERRIDES  CREATED_AT
```

2. Persist a candidate state with `--write @new-candidate`
```javascript
$ kerbi template demo \
        --write-state @new-candidate \
        > manifest.yaml

# States are in "candidate" status until you promote them, usually after
# applying the new manifest to your cluster (i.e `kubectl apply -f manifest.yaml`).
```


3. Use `list`, `promote`, and `retag`
```javascript
$ kerbi state list
 TAG                 MESSAGE  ASSIGNMENTS  OVERRIDES  CREATED_AT
 [cand]-angry-syrup           2            0          4 seconds ago

$ kerbi state promote @candidate
Updated state[angry-syrup].tag from [cand]-angry-syrup => angry-syrup

$ kerbi state show @latest
 --------------------------------------------
 TAG              angry-syrup
--------------------------------------------
 MESSAGE
--------------------------------------------
 CREATED_AT       2022-04-12 14:43:24 +0100
--------------------------------------------
 VALUES           pod.image: nginx          
                  service.type: ClusterIP
--------------------------------------------
 DEFAULT_VALUES   pod.image: nginx          
                  service.type: ClusterIP
--------------------------------------------
 OVERRIDDEN_KEYS
--------------------------------------------

$ kerbi state retag @latest 1.0.0
Updated state[1.0.0].tag from angry-syrup => 1.0.0
```

4. Use the values from `@latest` in our next templating operation, ad infinitum:

```javascript
$ kerbi template demo \
        --set pod.image=centos \
        --read-state @latest \
        --write-state @new-candidate \
        > manifest.yaml

$ kerbi state list
 TAG                MESSAGE  ASSIGNMENTS  OVERRIDES  CREATED_AT
 [cand]-tame-basin           2            1          5 seconds ago
 1.0.0                       2            0          2 minutes ago
```

### 🚦 Powerful Templating Orchestration Layer

You define `Mixer` classes from where you explicitly load up your 
lower level template files (say `deployment.yaml.erb`), other mixers,
entire directories, or even raw Helm charts. 

**`backend/mixer.rb`**
```ruby
class MyApp::Backend::Mixer < Kerbi::Mixer
  include MyApp::Common::KubernetesLabels

  def mix
    push file("deployment")
    push file("pvc") if persistence_enabled?
    push(mixer(ServiceMixer) + file("ingress"))
    
    patched_with file("annotations") do
      push chart("my-legacy/helm-chart")
      push dir("./../rbac", only: [{kind: 'ClusterRole.*'}])
    end
  end 
  
  def persistence_enabled?
    values.dig(:database, :enabled).present?
  end
end
```

You can opt for trivial or complicated mixers, depending on your needs and taste. They
primarily exist to 1) help you keep real logic out of your template files, and 2) let 
you organize your project as you see fit.

## ⌨️ Interactive Console

My favorite thing about CDK8s is that it feels like a normal computer program. 
Kerbi takes that one step further by letting you run your code in interactive mode (via IRB), 
making it super easy to play with and debug your code:

```ruby
$ kerbi console --set backend.database.enabled=true

irb(kerbi):001:0> values
=> {:backend=>{:database=>{:enabled=>"true"}}}

irb(kerbi):002:0> MyApp::Backend::Mixer.new(values).persistence_enabled?
=> true

irb(kerbi):003:0> MyApp::Backend::Mixer.new(values).run
=> [{:apiVersion=>"appsV1", :kind=>"Deployment", :metadata=>{:name=>"backend", :namespace=>"default"}, :spec=>"foo"}]
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
