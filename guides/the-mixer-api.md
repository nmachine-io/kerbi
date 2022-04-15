---
description: How to make the most of your MIxer subclasses
---

# The Mixer API

Mixers are your templating orchestration layer**.** Inside a mixer, you load various types of dict-yielding things, like YAML/ERB files, Helm charts, or other mixers, then manipulate their output if need be, and submit their final output.&#x20;

This page is about the [**`Kerbi::Mixer`**](https://github.com/nmachine-io/kerbi/blob/main/lib/main/mixer.rb) which is class. Find the complete method-level [**documentation here**](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer).

## The essentials: [`mix()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#mix-instance\_method) and [`push()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#push-instance\_method)``

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
$ kerbi template default

hello: Mister Kerbi
---
hola: Señor Kerbi
---
bonjour: Monsieur Kerbi
```
{% endtab %}
{% endtabs %}

**Some Observations:**

`mix()` is the method for all your mixer's logic.

`push(dicts: Hash | Array<Hash>)` adds the dict(s) you give it to the mixer's final output.

## Attributes: [`values`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#values-instance\_method) and [`release_name`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#release\_name-instance\_method)``

Mixers are instantiated with three important attributes:

**`values: Hash`** is an immutable dict containing the values compiled by Kerbi at start time (gathered from `values.yaml`, extra values files, and inline `--set x=y` assignments).

**`release_name: String`** the value of `template [RELEASE_NAME]`.

**`namespace: String`** the value of `--namespace [NAMESPACE]` from the CLI, if you pass it.



Accessing `values` and `release_name` is straightforward:

{% tabs %}
{% tab title="Mixer" %}
{% code title="kerbifile.rb" %}
```ruby
class AttributesDemoMixer < Kerbi::Mixer
  def mix
    push { x_equals: values[:x] } 
    push { release_name: release_name }
  end
end

Kerbi::Globals.mixers << AttributesDemoMixer
```
{% endcode %}
{% endtab %}

{% tab title="Output" %}
```yaml
$ kerbi template default --set x=y

x_equals: y
---
release_name: my-kubernetes-namespace
```
{% endtab %}
{% endtabs %}

It is recommended you use the `release_name` value for the `namespace` in you Kubernetes resource descriptors.

## The Dict-Extraction Methods

This is the meat of Mixers. The following functions let you load different types of files, and get the result back as a normalized, sanitized list of dicts (i.e `Array<Hash>`).

{% hint style="info" %}
**The methods below return a plain old `Array<Hash>`**

While the examples below just `push` immediately, it's important to understand that you're free to intercept and process what you're `push`ing:
{% endhint %}

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
{% endtab %}

{% tab title="Files with Dicts" %}
```yaml
key: value
more_key: more_value
--
key: value
```
{% endtab %}

{% tab title="Output" %}
```ruby
$ kerbi console
mixer = MeddlingMixer.new
mixer.have_fun!
=> I'm just an Array of Hash!
=> Containing: [{key: value, more_key: more_value}, {key: value}]
```


{% endtab %}
{% endtabs %}

Then sandboxing it:

### The [`file()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#file-instance\_method) method

Use `file()` to load a YAML, JSON, or ERB file containing one or many descriptors that can be turned into dicts. For example:

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

### The [`dir()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#dir-instance\_method) method

Use `dir()` to load YAML, JSON, or ERB files in a given directory.

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
│   ├───file-one.yaml
│   ├───file-two.yaml
```
{% endtab %}

{% tab title="Files in the Directory" %}
{% code title="foo-dir/file.yaml" %}
```yaml
file_one: one
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
$ kerbi template default

file_one: one
---
file_two: two
```
{% endtab %}
{% endtabs %}

### The [`patched_with()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#patched\_with-instance\_method) method

As a convenience, you can have dicts patched onto the dicts that you emit. This is a common pattern for things like annotations and labels on Kubernetes resources. With `patched_with()`, all invokations of `file()`, `dir()`, `chart()`,  `mixer()`,  or `http`()  you place inside the block will have the specified dicts merged onto their outputs.

Below are several examples:

{% tabs %}
{% tab title="Simple Example" %}
{% code title="kerbifile.rb" %}
```ruby
class SimplePatch < Kerbi::Mixer
  def mix
    patched_with(x: {new_y: "new-z"}) do
      push x: { y: "z" }
    end
  end
end
```
{% endcode %}
{% endtab %}

{% tab title="Practical Example" %}
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
{% endtab %}
{% endtabs %}

Output for the examples above:

{% tabs %}
{% tab title="Simple Example" %}
```yaml
x:
  y: "y"
  new_y: "new-z"
```
{% endtab %}

{% tab title="Practical Example" %}
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

### The [`chart()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixer#chart-instance\_method) method

You can use Kerbi to run Helm as well . The `chart()` method is more or less a wrapper that calls Helm's [template command](https://helm.sh/docs/helm/helm\_template/), i.e `helm template <release-name> <location>`.&#x20;

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
    chart(
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
# on and o
```
{% endtab %}
{% endtabs %}

## Filtering Resources with `only` and `except`

You can filter the outputs of the extraction methods seen above by using the `only` and `except` options. Each accepts an **`Array<Hash>`** where each **`Hash`** should follow the schema:

`kind: String | nil # compared to <resource>.kind`

`name: String | nil # compared to <resource>.metadata.name`

{% hint style="info" %}
**Important**

* Omiting `name` or `kind` is the same as saying "any" for that attribute.&#x20;
* You can pass a _quasi_ regex, which will get interpreted as `"^#{your_expr}$`
{% endhint %}

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
$ kerbi template default
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wanted
```
{% endtab %}
{% endtabs %}





&#x20;
