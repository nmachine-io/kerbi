
# The Kerbi Templating Engine for Kubernetes

[![codecov](https://codecov.io/gh/nectar-cs/kerbi/branch/master/graph/badge.svg)](https://codecov.io/gh/nectar-cs/kerbi)
[![Gem Version](https://badge.fury.io/rb/kerbi.svg)](https://badge.fury.io/rb/kerbi)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What is Kerbi?

**Kerbi is a templating engine** for generating Kubernetes manifests. 
On the outside, it operates very similarly to [Helm](https://helm.sh/), turning 
variables + templates into Kubernetes-bound YAML, and even has similar command line API.

**Versus Helm**, it is designed to have 1) a better developer experience, 2) more power, 3) more flexibility. 
It is also a pure templating engine - it does not "package" things, or talk to Kubernetes for you, it just turns X into YAML.

**The name Kerbi** is an acronym for Kubernetes [ERB](https://www.stuartellis.name/articles/erb/) Interpolator. 
And just like the [pink Kirby](https://en.wikipedia.org/wiki/Kirby_(character)), 
it sucks up just about anything, and spits out something useful.

**[Documentation Site.](https://xavier-9.gitbook.io/untitled/walkthroughs/getting-started)**

## Getting Started

Install the `kerbi` RubyGem globally: 

```bash
$ gem install kerbi
```

Now use the new `kerbi` executable to initialize a project and install the dependencies:

```bash
$ kerbi project new hello-kerbi
Created project at /home/<my-workspace>/hello-kerbi
Created file hello-kerbi/Gemfile
#...

$ cd hello-kerbi
$ bundle install
```

Voila. Generate your first manifest with:

```yaml
$ kerbi template default .
message: default message
```

**[See the complete walkthroughs and more.](https://xavier-9.gitbook.io/untitled/walkthroughs/getting-started)**

## The Developer Experience

Kerbi lets you write programmatic mixers in Ruby to orchestrate complex (or silly) templating logic:    

**`backend/mixer.rb`**
```ruby
class Hooli::Backend::Mixer < Kerbi::Mixer
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

Most of the actual templating happens in `.yaml.erb` files, which the mixer above loads:

**`deployment.yaml.erb`**
```yaml
apiVersion: appsV1
kind: Deployment
metadata:
  name: backend
  namespace: <%= release_name %>
  labels: <%= embed(common_labels, indent: 3) %>
spec: 
  replicas: <%= values[:deployment][:replicas] %>
```

And like with Helm, you pass values with a default `values.yaml` plus any custom files:

**`values/production.yaml`**
```yaml
deployment:
  replicas: 10
```

You then generate your final Kubernetes-bound YAML like this:

```bash
$ kerbi template my-namespace . -f production.yaml
```
 
Kerbi can also be run in interactive mode (via IRB), making it easy to play
with your code:

```ruby
$ kerbi console
backend_mixer = Hooli::Backend::Mixer.new(@values)
backend_mixer.persistence_enabled?
=> true
backend_mixer.file("deployment")
=> [{apiVersion: "appsV1", kind: "Deployment", #...}]
```


## Why Kerbi over Helm?

The thesis with Kerbi is this: reality is messy, and our templating needs often break structural 
molds (like Helm's), so let's make an engine with less structure and more power, 
so that you can model it to your needs.

**🔀 More ways to template and manipulate data**. 
Kerbi lets you deal directly with dicts (or Hashes in Ruby speak), and makes it easy to extract 
dicts from things like files, directories, static manifests, or even Helm charts, into dicts, 
letting you implement complex multi-source templating strategies.

**🏗 Freedom to organize and extend**. 
With Kerbi, you're just writing a program. 
You can require files how you see fit, meaning you can have any directory structure you want. 
You can also add functionality in any way you want, being constrained only by Ruby and its packages.

**💎 Ruby at its best**. 
Ruby is not longer a top tier language for web apps 😞. 
But when it comes to narrow programs that involve DSLs and config mgmt, Ruby remains second to none. 
The developer experience in Ruby is way better to what you get for these kinds of programs with Go in Helm.


## Running the Examples

Have a look at the [examples](https://github.com/nmachine-io/kerbi/tree/master/examples) directory. 
If you want to go a step further and run them from source, clone the project, `cd` into the example you 
want, and run 
```bash
$ ./run [CLI COMMAND AND OPTIONS] 
```
This will use the local code instead of your global `kerbi` executable. For example:

```bash
$ cd examples/hello-yaml
$ ./run template default .
```

## Contributing

See [CONTRIBUTING.md](https://github.com/nmachine-io/kerbi/blob/master/CONTRIBUTING.md)
