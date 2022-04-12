# Welcome

## What is Kerbi?

**Kerbi is a templating engine** for generating Kubernetes manifests. On the outside, it operates very similarly to [Helm](https://helm.sh), turning variables + templates into Kubernetes-bound YAML, and even has similar command line API.

**Versus Helm**, it is designed to have 1) a better developer experience, 2) more power, 3) more flexibility. It is also a pure templating engine - it does not "package" things, or talk to Kubernetes for you, it just turns X into YAML.

**The name Kerbi** is an acronym for Kubernetes [ERB](https://www.stuartellis.name/articles/erb/) Interpolator. And just like the [pink Kirby](https://en.wikipedia.org/wiki/Kirby\_\(character\)), it sucks up just about anything, and spits out something useful.

![](https://storage.googleapis.com/kerbi/images/kerbi-intro.png)

## How it Looks

{% code title="project/kerbifile.rb" %}
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
{% endcode %}

ERB files like `"pod"` can invoke your mixer's instance methods, Kerbi's default helper methods (Base64 encoding, embedding, nullity, etc...), or really anything you can write in Ruby:

{% code title="project/deployment.yaml.erb" %}
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
{% endcode %}

And like with Helm, you pass values with a default `values.yaml` plus any custom files:

{% code title="project/values/production.yaml" %}
```yaml
deployment:
  replicas: 10
```
{% endcode %}

Run it like a Helm chart:

```bash
$ kerbi template my-namespace . -f production.yaml > manifest.yaml
```

Kerbi can also be run in interactive mode (via IRB), making it easy to play with your code:

```ruby
$ kerbi console --set backend.database.enabled=true

irb(kerbi):001:0> values
=> {:backend=>{:database=>{:enabled=>"true"}}}

irb(kerbi):002:0> Hooli::Backend::Mixer.new(values).persistence_enabled?
=> true

irb(kerbi):003:0> Hooli::Backend::Mixer.new(values).run
=> [{:apiVersion=>"appsV1", :kind=>"Deployment", :metadata=>{:name=>"backend", :namespace=>"default"}, :spec=>"foo"}]
```

## Why Kerbi over Helm?

The thesis with Kerbi is this: reality is messy, and our templating needs often break structural molds (like Helm's), so let's make an engine with less structure and more power, so that you can model it to your needs.

**🔀 More ways to template and manipulate data**. Kerbi lets you deal directly with dicts (or Hashes in Ruby speak), and makes it easy to extract dicts from things like files, directories, static manifests, or even Helm charts, into dicts, letting you implement complex multi-source templating strategies.

**🏗 Freedom to organize and extend**. With Kerbi, you're just writing a program. You can require files how you see fit, meaning you can have any directory structure you want. You can also add functionality in any way you want, being constrained only by Ruby and its packages.

**💎 Ruby at its best**. Ruby is not longer a top tier language for web apps 😞. But when it comes to narrow programs that involve DSLs and config mgmt, Ruby remains second to none. The developer experience in Ruby is way better to what you get for these kinds of programs with Go in Helm.

## Why Helm over Kerbi?

Aside from the obvious fact that Helm is now mature and widely adopted, the main reasons you would choose Helm over Kerbi are:

**Consistency across projects**. Two Helm projects are more likely to look alike than two Kerbi projects. Turing complete means programmers will spill more of their unique styles onto projects.

**Kerbi Requires Having Ruby**. You need to have whichever version of Ruby the project requires running on your machine.

**More code, more bugs**. Depending on how you write your Kerbi mixers, you can end up with a lot of code, which may be a liability.&#x20;

