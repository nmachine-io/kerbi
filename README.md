
# The Kerbi Templating Engine for Kubernetes

[![codecov](https://codecov.io/gh/nectar-cs/kerbi/branch/master/graph/badge.svg)](https://codecov.io/gh/nectar-cs/kerbi)
[![Gem Version](https://badge.fury.io/rb/kerbi.svg)](https://badge.fury.io/rb/kerbi)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# What is Kerbi?

**Kerbi is a templating engine** for generating Kubernetes manifests. 
On the outside, it operates very similarly to [Helm](https://helm.sh/), turning 
variables + templates into Kubernetes-bound YAML, and even has similar command line API.

**Versus Helm**, it is designed to have 1) a better developer experience, 2) more power, 3) more flexibility. 
It is also a pure templating engine - it does not "package" things, or talk to Kubernetes for you, it just turns X into YAML.

**The name Kerbi** is an acronym for Kubernetes [ERB](https://www.stuartellis.name/articles/erb/) Interpolator. 
And just like the [pink Kirby](https://en.wikipedia.org/wiki/Kirby_(character)), 
it sucks up just about anything, and spits out something useful.

![](https://storage.googleapis.com/kerbi/images/kerbi-intro.png)

**[Documentation Site.](https://xavier-9.gitbook.io/untitled/walkthroughs/getting-started)**

# Getting Started

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

# The Developer Experience

As a user, the main difference between Helm and Kerbi projects is this:

**🚦 Kerbi requires an Explicit Control Flow**. Where Helm uses a directory structure convention
to figure out what to do with your files, Kerbi makes you write **Mixers** in plain Ruby, 
where you explictly say "template this file here and that chart there".

**📁 Kerbi accepts various types of files**. Because Kerbi has your write actual programs,
you can easily use or build new **extractor methods** like `file()` to load, interpolate, and normailze
anything into `dicts` (e.g `Array<Hash>`), which are Kerbi thinks in.

## Mixers

Mixers don't exist in Helm. They may seem like an extra step, but when your logic starts to grows,
mixers are an excellent way to stay DRY, readable, and organized.

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
Extractor methods like `file()` and `dir()` load 

## Templating

Most of the actual templating happens in `.yaml.erb` files, which the mixer above loads:

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
      containers: <%= embed_array(file('containers')) %>
```

## Values

Like with Helm, values for your templating logic come from YAML files, namely your default
`values.yaml`, inline assignments in the command like `--set backend.ingress.enabled=false`, 
plus any custom files you load via CLI, e.g `-f production.yaml`:

**`values/production.yaml`**
```yaml
backend:
  deployment:
    replicas: 10
```

## CLI

Generate your final Kubernetes-bound YAML or JSON as you do with Helm:

```bash
$ kerbi template my-namespace . -f production.yaml -o json
```

Print out values etc with other commands like

```bash
$ kerbi values show --set backend.ingress.enabled=false
```
 
## Interactive Console
 
Kerbi can also be run in interactive mode (via IRB), making it super easy to play
with your code and debug things:

```ruby
$ kerbi console --set backend.database.enabled=true

irb(kerbi):001:0> values
=> {:backend=>{:database=>{:enabled=>"true"}}}

irb(kerbi):002:0> Hooli::Backend::Mixer.new(values).persistence_enabled?
=> true

irb(kerbi):003:0> Hooli::Backend::Mixer.new(values).run
=> [{:apiVersion=>"appsV1", :kind=>"Deployment", :metadata=>{:name=>"backend", :namespace=>"default"}, :spec=>"foo"}]
```


## Why use Kerbi over Helm?

The thesis with Kerbi is this: reality is messy, and our templating needs often break clean 
structural molds like Helm's, so let's make an engine with less structure and more power, 
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
While Helm can feel a bit mysterious, Kerbi feel familiar to anyone familiar with programming and libraries in general.

## Why use Helm over Kerbi?

With great Turing-completeness comes the potential for great stupidity. If you love over-engineering, 
re-inventing wheels, obsessing over DRYness, or library-creeping, then you are at risk of abusing
Kerbi and plunging your team into tyranny. Kerbi responsibly.

## Running the Examples

Have a look at the [examples](https://github.com/nmachine-io/kerbi/tree/master/examples) directory. 
If you want to go a step further and run them from source, clone the project, `cd` into the example you 
want. For instance:

```bash
$ cd examples/hello-kerbi
$ kerbi template default .
```

## Contributing

See [CONTRIBUTING.md](https://github.com/nmachine-io/kerbi/blob/master/CONTRIBUTING.md)
