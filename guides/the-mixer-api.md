---
description: How to make the most of your MIxer subclasses
---

# The Mixer API

Mixers are your templating orchestration layer. Inside a mixer, you load various types of dict-yielding things, like YAML/ERB files, Helm charts, or other mixers, then manipulate their output if need be, and submit their final output.

This page is about the [**`Kerbi::Mixer`**](https://github.com/nmachine-io/kerbi/blob/main/lib/main/mixer.rb) which is a class. Find the complete [**documentation here**](https://www.rubydoc.info/gems/kerbi/Kerbi/Mixer).

{% hint style="info" %}
**We use the words "Dict" and "**[**Hash**](https://ruby-doc.org/core-3.1.1/Hash.html)**" interchangeably**
{% endhint %}

## The essentials: [`mix()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#mix-instance\_method) and [`push()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#push-instance\_method)

When you subclass a `Kerbi::Mixer`, you _have_ to call `mix` and `push` if you want to do anything useful. The `mix` method is what the engine invokes at runtime. Inside your `mix` method, you call `push` to say "include this dict or these dicts in the final output".

{% tabs %}
{% tab title="Mixer" %}
{% code title="kerbifile.rb" %}
```ruby
class TrivialMixer < Kerbi::Mixer
  def mix
    push { hello: "Mister Kerbi" }
    push [{ hola: "Señor Kerbi", bonjour: "Monsieur Kerbi" }] 
  end
end

Kerbi::Globals.mixers << TrivialMixer
```
{% endcode %}
{% endtab %}

{% tab title="Output" %}
```yaml
$ kerbi template default .

hello: Mister Kerbi
---
hola: Señor Kerbi
---
bonjour: Monsieur Ke
```
{% endtab %}
{% endtabs %}

**Some Observations:**

**`mix()`** is the method for all your mixer's logic.

**`push(dicts: Hash | Array<Hash>)`** adds the dict(s) you give it to the mixer's final output.

## Attributes: [`values`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#values-instance\_method) and [`release_name`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#release\_name-instance\_method)

Mixers are instantiated with two important attributes: `values` and `release_name`.

**`values: Hash`** is an immutable dict containing the values compiled by Kerbi at start time (gathered from `values.yaml`, extra values files, and inline `--set x=y` assignments).

**`release_name: String`** holds the `release_name` value, which is the second argument you pass in the CLI in the `template` command.

Accessing `values` and `release_name` is straightforward:

{% tabs %}
{% tab title="Mixer" %}
{% code title="kerbifile.rb" %}
```ruby
class HelloMixer < Kerbi::Mixer
  def mix
    push { x: values[:x] } 
    push { x: release_name }
  end
end

Kerbi::Globals.mixers << HelloMixer
```
{% endcode %}
{% endtab %}

{% tab title="Output" %}
```yaml
$ kerbi template beaver . --set x=y

x: y
---
x: beaver
```
{% endtab %}
{% endtabs %}

It is recommended you use the `release_name` value for the `namespace` in you Kubernetes resource descriptors, <mark style="color:yellow;">**however it is entirely up to you**</mark>.

## The Dict-Loading Methods

This is the meat of Mixers. The following functions let you load different types of files, and get the result back as a normalized, sanitized list of dicts (i.e `Array<Hash>`).

{% tabs %}
{% tab title="Mixer" %}
{% code title="kerbifile.rb" %}
```ruby
class MeddlingMixer < Kerbi::Mixer
  def have_fun!
    extracted = file("yaml")
    puts "I'm just an #{extracted.class} of #{extracted[0].class}!"
    puts "Containing: #{just_dicts}"
  end
end
```
{% endcode %}

\
Testing:

```ruby
$ kerbi console
irb(kerbi):001:0> mixer = MeddlingMixer.new
irb(kerbi):002:0> mixer.have_fun!
=> I'm just an Array of Hash!
=> Containing: [{key: value, more_key: more_value}, {key: value}]
```
{% endtab %}

{% tab title="Files with Dicts" %}
```yaml
key: value
more_key: more_value
--
key: value

```


{% endtab %}
{% endtabs %}

### The [`dicts()`](https://www.rubydoc.info/gems/kerbi/Kerbi/Mixer#dicts-instance\_method) method (aka [`dict()`](https://www.rubydoc.info/gems/kerbi/Kerbi/Mixer#dicts-instance\_method) )

The core dict-loading method, called by every other dict loading method (`file()` etc...). Has two purposes:&#x20;

1. Sanitizing its inputs, turning a single `Hash`, into an `Array<Hash>`, transforming non-symbol keys into symbols, raising errors if its inputs are not Hash-like, etc...
2. Performing post processing according to the options it receives, [**covered below**](the-mixer-api.md#post-processing).

**Use it anytime** you want to push dicts that did not come directly from another dict loading method (`file()` etc...). Not doing so and pushing dicts directly can lead to errors.

```ruby
class DictMixer < Kerbi::Mixer
  def mix
    push dict({"weird_key" => "fixed!"})
  end
end
```

### The [`file()`](https://www.rubydoc.info/gems/kerbi/Kerbi/Mixer#file-instance\_method) method

Loads one YAML, JSON, or ERB file containing one or many descriptors that can be turned into dicts.&#x20;

You can omit the file name extensions, e.g `file-one.json` can be referred to as `"file-one"`. In general, an extension-less name will trigger a search for:

```
<name>.yaml
<name>.json
<name>.yaml.erb
<name>.json.erb
```

{% tabs %}
{% tab title="Mixer" %}
{% code title="kerbifile.rb" %}
```ruby
class FileMixer < Kerbi::Mixer
  def mix
    push file("file-one")
    push file("dir/file-two")
  end
end

Kerbi::Globals.mixers << FileMixer
```
{% endcode %}
{% endtab %}

{% tab title="YAML & JSON Files" %}
{% code title="file-one.yaml" %}
```yaml
file_one: one
```
{% endcode %}

{% code title="dir/file-two.json" %}
```yaml
{"file_two": "two"}
```
{% endcode %}
{% endtab %}

{% tab title="Output" %}
```yaml
$ kerbi template default

foo_file: foo
---
bar_file: bar
```
{% endtab %}

{% tab title="Project" %}
```
<project root>
├───kerbifile.rb
├───file-one.yaml
├───dir
│   ├───file-two.json
```
{% endtab %}
{% endtabs %}

### The [`dir()`](https://www.rubydoc.info/gems/kerbi/Kerbi/Mixer#dir-instance\_method) method

Loads **all** YAML, JSON, or ERB files in a given directory. Scans for the following file extensions:&#x20;

```
*.yaml
*.json
*.yaml.erb
*.json.erb
```

{% tabs %}
{% tab title="The Mixer" %}
{% code title="kerbifile.rb" %}
```ruby
class DirMixer < Kerbi::Mixer
  def mix
    push dir("foo-dir")
  end
end

Kerbi::Globals.mixers << DirMixer
```
{% endcode %}
{% endtab %}

{% tab title="Project" %}
```
<project root>
├───kerbifile.rb
├───foo-dir
│   ├───file-one.json
│   ├───file-two.yaml
```
{% endtab %}

{% tab title="Files" %}
{% code title="foo-dir/file-one.json" %}
```yaml
{ "file_one": "one" }
```
{% endcode %}

{% code title="foo-dir/file-two.yaml" %}
```yaml
file_two: two
```
{% endcode %}
{% endtab %}

{% tab title="Output" %}
```yaml
$ kerbi template demo .

file_one: one
---
file_two: two
```
{% endtab %}
{% endtabs %}

### The [`mixer()`](https://www.rubydoc.info/gems/kerbi/Kerbi/Mixer#mixer-instance\_method)  method

Instantiates the given mixer, runs it, and returns its output as an `Array<Hash>`.&#x20;

{% tabs %}
{% tab title="Main" %}
{% code title="kerbifile.rb" %}
```ruby
require_relative 'other_mixer'

module MultiMixing
  class MixerOne < Kerbi::Mixer
    def mix
      push(mixer_says: "MixerOne #{values}")
    end
  end

  class OuterMixer < Kerbi::Mixer
    def mix
      push mixer_says: "OuterMixer #{values}"
      push mixer(MultiMixing::MixerOne)
      push mixer(MultiMixing::MixerTwo, values: values[:x])
    end
  end
end

Kerbi::Globals.mixers << MultiMixing::OuterMixer
Kerbi::Globals.revision = "1.0.0"
```
{% endcode %}
{% endtab %}

{% tab title="Mixer in second file" %}
{% code title="other_mixer.rb" %}
```ruby
module MultiMixing
  class MixerTwo < Kerbi::Mixer
    def mix
      push(mixer_says: "MixerTwo #{values}")
    end
  end
end
```
{% endcode %}
{% endtab %}

{% tab title="Output" %}
```yaml
$ kerbi template demo . --set x.y=z

mixer_says: OuterMixer {:x=>{:y=>"z"}}
---
mixer_says: MixerOne {:x=>{:y=>"z"}}
---
mixer_says: MixerTwo {:y=>"z"}
```
{% endtab %}
{% endtabs %}

Observations:

* **`require_relative`** imports the other mixer in plain Ruby, no magic
* **`mixer(MultiMixing::MixerOne)` ** takes a class, not an instance
* **`values: values[:x]`** lets us customize the values the inner mixer gets

### The [`helm_chart()`](https://www.rubydoc.info/gems/kerbi/Kerbi/Mixer#helm\_chart-instance\_method) method

Invokes Helm's [template command](https://helm.sh/docs/helm/helm\_template/), i.e `helm template [NAME] [CHART]` and returns the output as a standard `Array<Hash>`.&#x20;

Here is an example using [JetStack's cert-manager chart](https://artifacthub.io/packages/helm/cert-manager/cert-manager)

{% tabs %}
{% tab title="Mixer" %}
{% code title="kerbifile.rb" %}
```ruby
class HelmExample < Kerbi::Mixer
  def mix
    push cert_manager_resources
  end

  def cert_manager_resources
    helm_chart(
      'jetstack/cert-manager',
      release: release_name,
      values: values.dig(:cert_manager)
    )
  end
end

Kerbi::Globals.mixers << HelmExample
```
{% endcode %}
{% endtab %}

{% tab title="Output" %}
```
apiVersion: v1
kind: ServiceAccount
automountServiceAccountToken: true
metadata:
  name: default-cert-manager-cainjector
  namespace: default
  labels:
    app: cainjector
    app.kubernetes.io/name: cainjector
    app.kubernetes.io/instance: default
    app.kubernetes.io/component: cainjector
    app.kubernetes.io/version: v1.7.1
    app.kubernetes.io/managed-by: Helm
    helm.sh/chart: cert-manager-v1.7.1
---
# on and on
```
{% endtab %}
{% endtabs %}

Your local Helm installation must be ready to accept this command, meaning:

1. The `repo` must be available to Helm (see [helm repo add](https://helm.sh/docs/helm/helm\_repo\_add/))
2. Your helm executable must be available (see [Global Configuration](global-configuration.md))

## Post Processing

### The [`patched_with()`](https://www.rubydoc.info/gems/kerbi/Kerbi/Mixer#patched\_with-instance\_method) method

As a convenience, you can have dicts patched onto the dicts that you emit. This is a common pattern for things like annotations and labels on Kubernetes resources.&#x20;

**Only affects** dicts processed by dict-loading methods, i.e callers of `dict()`, so `file()`, `dir()`, `helm_chart()`, and `mixer()` . If you `push()` a raw `Hash` or `Array<Hash>`, it will **not** get patched. You can also escape patching in dict-loaders with `no_patch:  true.`

{% tabs %}
{% tab title="Simple" %}
{% code title="kerbifile.rb" %}
```ruby
class SimplePatch < Kerbi::Mixer
  def mix 
    datas = { x: { y: "z" } } 
    patch = { x: { y2: "y2" } }

    patched_with patch do
      push dict(datas)
      push datas
    end
  end
end
```
{% endcode %}



Output: &#x20;

```yaml
$ kerbi template demo .
x:
  y: "z"
  y2: "y2"
--
x: 
  y: "z"
```
{% endtab %}

{% tab title="Practical" %}
{% code title="kerbifile.rb" %}
```ruby
class PatchWithFile < Kerbi::Mixer
  def mix
    patched_with file("annotations") do
      push file("namespace-and-cm")
    end
  end
end
```
{% endcode %}



Assuming the annotations file:

{% code title="annotations.yaml.erb" %}
```yaml
metadata:
  annotations:
    generated_by: "kerbi"
    author: <%= ENV["USER"] %>
```
{% endcode %}



And the Kubernetes namespace/cm file:

{% code title="namespace-and-cm.yaml.erb" %}
```yaml
apiVersion: v1
kind: Namespace
metadata: 
  name: <%= release_name %>

---

apiVersion: v1
kind: ConfigMap
metadata: 
  name: configmap
  namespace: <%= release_name %>
```
{% endcode %}

\
And the output:

```yaml
apiVersion: v1
kind: Namespace
metadata: 
  name: patching
  annotations:
    generated_by: kerbi
    author: gavin_belson  

---

apiVersion: v1
kind: ConfigMap
metadata: 
  name: configmap
  namespace: patching
  annotations:
    generated_by: kerbi
    author: gavin_belson
```
{% endtab %}
{% endtabs %}

{% hint style="warning" %}
**Avoid patching your patches!**

You can have nested patches, but make sure that the inner patch _itself_ is not patched with the outer patch. To do this, **pass `no_patch: true` to any dict-loading** method you use to load the patch contents:&#x20;
{% endhint %}

```ruby
class SimplePatch < Kerbi::Mixer
  def mix
    patched_with(x: {new_y: "new-z"}) do
      patched_with file("inner-patch", no_patch: true) do
        push business: "as_usual"
      end
    end
  end
end
```

### Filtering Resource Dicts

You can filter the outputs any dict loader method seen above by using the **`only` and `except` options**. Each accepts an **`Array<Hash>`** where each **`Hash`** should follow the schema:

`kind: String | nil # compared to <resource>.kind`

`name: String | nil # compared to <resource>.metadata.name`

{% tabs %}
{% tab title="Mixer" %}
```ruby
class FilteringExample < Kerbi::Mixer
  ONLY = [{kind: "PersistentVolume.*"}]
  EXCEPT = [{name: "unwanted"}]

  def mix
    push file('resources', only: ONLY, except: EXCEPT)
  end
end

Kerbi::Globals.mixers << FilteringExample
```
{% endtab %}

{% tab title="Template" %}
{% code title="resources.yaml" %}
```yaml
apiVersion: v1
kind: VolumeClaim
metadata:
  name: unwanted

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wanted

---

apiVersion: v1
kind: Pod
metadata:
  name: "also-unwanted"
```
{% endcode %}
{% endtab %}

{% tab title="Output" %}
```yaml
$ kerbi template default .
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wanted
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
**Important**

* Omitting `name` or `kind` is the same as saying "any" for that attribute.
* You can pass a _quasi_ regex, which will get interpreted as `"^#{your_expr}$.`  For example, `"PersistentVolume.*"` will do what you expect and also match "PersistentVolumeClaim".&#x20;
{% endhint %}
