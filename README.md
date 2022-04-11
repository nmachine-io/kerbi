
# Kerbi

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

```bash
$ kerbi project new hello-kerbi
$ cd hello-kerbi
```

Voila. You can now generate templates and manage state:

```
$ kerbi template demo --set message=special
text: special demo message
```

## Drawing from Helm, Kapitan, and CDK8s

### 💲 Kerbi is Variable (aka Value) Based like Helm

Like with Helm, your control knobs are key-value pairs that you pass in at runtime,
which your templating logic uses to interpolate the final manifest. Your have your 
baseline `values.yaml` file, override files passed via CLI, e.g
`-f production.yaml`, inline assignments, e.g `--set backend.ingress.enabled=false`,
and previously committed values, e.g `--read-state @latest`

**`production.yaml`**
```yaml
backend:
  deployment:
    replicas: 30
```

You can also easily inspect fully merged values before templating:

```yaml
$ kerbi values show -f production --set backend.image=centos --read-state tango
backend:
  deployment:
    replicas: 30
```

Zero innovation here because Helm does it perfectly.

### 📀 State Management is Explicit and Non-Invasive

Variable based templating is only feasible IRL if you have a way to store and retreive 
the sets of variables you generate your manifests with. If you template and apply 
with `--set backend.image=2` and later want to `--set frontend.image=2`, you'll need to have a way 
keep `backend.image` equal to `2`, otherwise it will get reverted to its old value. You _could_ use git, 
but that's not ideal.

Thus, Helm and Kerbi have a notion of "state", where information about template-generating
operations can be persisted to a `ConfigMap`. Unlike Helm, which couples state with a heavy 
handed concept of "releases" (modifies your resources, kubectl's for you, etc...), Kerbi opts 
for an explicit, non-invasive API: `--read-state` and `--write-state`, that only records 
computed values.

Start by explicitly setting up state tracking:
```
kerbi 
```

1) Kerbi's CLI much more explicit controls,nforcing the user to be deliberate. Additionally, 

```bash
$ kerbi template my-app \
        --set backend.image=thing:1.0.1 \
        --read-state @latest \
        --write-state @candidate \       
        >> manifest.yaml
```

```
table
```

### 📜 The Templating Languages are Familiar to Most

Helm's Go-in-YAML might be awkward, but makes the right choice of sticking to Kubernetes' lingua franca - YAML.
Kapitan and CDK8S offer a better DX, but only if you 1) know their dialects or object models well,
and 2) actually need hardcore templating everywhere in your project.

**`deployment.yaml.erb`**
```yaml
apiVersion: appsV1
kind: Deployment
metadata:
  name: <% Hooli::Backend::Consts::NAME %>
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

### 🚦 Powerful Templating Orchestration Layer

**`backend/mixer.rb`**
```ruby
class MyApp::Backend::Mixer < Kerbi::Mixer
  include Hooli::Common::KubernetesLabels
  values_root "backend"

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

### 🗣️ No Workflow Highjacking, No talking to K8s "for you"

A big design objective with state management was to avoid doing mission critical,
stressful operations like `kubectl apply` on your behalf. 

```bash
$ kerbi 
$ kerbi template my-app \
        --set backend.image=thing:1.0.1 \
        --read-state @latest \
        --write-state @candidate \       
        >> manifest.yaml

$ kubectl apply --dry-run -f manifest.yaml 

$ 

```

```bash
$ kerbi config use-namespace see-food
$ kerbi state test-connection
$ kerbi state init
$ kerbi state test-connection
```

## ⌨️ Interactive Console

My favorite thing about CDK8s is that it feels like a normal computer program. 

Kerbi takes that one step further by letting you run your code in interactive mode (via IRB), 
making it super easy to play with and debug your code:

```ruby
$ kerbi console --set backend.database.enabled=true

irb(kerbi):001:0> values
=> {:backend=>{:database=>{:enabled=>"true"}}}

irb(kerbi):002:0> Hooli::Backend::Mixer.new(values).persistence_enabled?
=> true

irb(kerbi):003:0> Hooli::Backend::Mixer.new(values).run
=> [{:apiVersion=>"appsV1", :kind=>"Deployment", :metadata=>{:name=>"backend", :namespace=>"default"}, :spec=>"foo"}]
```

## Getting Involved

If you're interesting in getting involved, thank you ❤️. 

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
