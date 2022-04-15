# Walkthrough

Let's do something useful: generate some Kubernetes-bound YAML. We'll create the resource descriptors for a tiny [Pod](https://kubernetes.io/docs/concepts/workloads/pods/) running `nginx` along with a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

We will recreate the [**hello-kerbi project**](https://github.com/nmachine-io/kerbi/tree/main/examples) from the examples folder. Read along or clone the folder to play with it locally. The directory structure by the end of the tutorial will be:

```
<project root>
├───kerbifile.rb
├───pod-and-service.yaml.erb
├───consts.rb
├───helpers.rb
├───values
│   ├───values.yaml
│   └───production.yaml
```

## 1. Basic Pod & Service

Starting simple, almost with static YAML, only interpolating `release_name`:

{% tabs %}
{% tab title="kerbifile.rb" %}
```ruby
class HelloWorld < Kerbi::Mixer
  def mix
    push file("pod-and-service")
  end
end

Kerbi::Globals.mixers << HelloWorld
```
{% endtab %}

{% tab title="pod-and-service.yaml.erb" %}
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: "hello-kerbi"
  namespace: <%= release_name %>
spec:
  containers:
    - name: main
      image: nginx

---

apiVersion: v1
kind: Service
metadata:
  name: "hello-kerbi"
  namespace: <%= release_name %>
spec:
  selector:
    app: "hello-kerbi"
  ports:
    - port: 80
```
{% endtab %}

{% tab title="Output" %}
{% code title="$ kerbi template demo" %}
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-kerbi
  namespace: demo
spec:
  containers:
  - name: main
    image: nginx

---

apiVersion: v1
kind: Service
metadata:
  name: hello-kerbi
  namespace: demo
spec:
  selector:
    app: hello-kerbi
  ports:
  - port: 80
```
{% endcode %}
{% endtab %}

{% tab title="Kubernetes" %}
```bash
$ kerbi template demo > manifest.yaml
$ kubectl apply -f manifest.yaml
```
{% endtab %}
{% endtabs %}

**A few Observations:**

`release_name` **** gets its value - `default` - from our command line argument

`file("pod-and-service")` omits the `.yaml.erb` extension and still works.

`push file()` is just passing an `Array<Hash>` returned by `file()`, explained [here](the-mixer-api.md#the-essentials-mix-and-push).

`require "kerbi"` is nowwhere to be found. That's normal, the `kerbi` executable handles it.

## 2. Adding Values

The whole point of templating engines is to modulate the output based on information passed at runtime. Like in Helm, the primary mechanism for this is **values**.&#x20;

{% tabs %}
{% tab title="values/values.yaml" %}
```yaml
pod:
  image: nginx
service:
  type: ClusterIP
```
{% endtab %}

{% tab title="pod-and-service.yaml.erb" %}
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: "hello-kerbi"
  namespace: <%= release_name %>
spec:
  containers:
    - name: main
      image: <%= values[:pod][:image] %>

---

apiVersion: v1
kind: Service
metadata:
  name: "hello-kerbi"
  namespace: <%= release_name %>
spec:
  type: <%= values[:service][:type] %>
  selector:
    app: "hello-kerbi"
  ports:
    - port: 80
```
{% endtab %}

{% tab title="values/production.yaml" %}
```yaml
service:
  type: LoadBalancer
```
{% endtab %}
{% endtabs %}

Running `kerbi template default .` yields the output you would expect. We can also choose to also apply our `production.yaml` by using `-f` flag in the command:

```
$ kerbi template demo -f production.yaml
```

This makes our Service become a LoadBalancer:

```yaml
kind: Service
#...
spec:
  type: LoadBalancer
  #...
```

Finally, we can use `--set` to achieve the same effect, but without creating a new values file:

```
$ kerbi template demo --set service.type=LoadBalancer
```

## 3. Patching After Loading

Suppose we want to add [labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) and [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) to our Pod and Service. Because this will happen a lot, we can use `patched_with` to patch several resources in one shot, rather than per-resource.

{% tabs %}
{% tab title="kerbifile.rb" %}
```ruby
class HelloWorld < Kerbi::Mixer
  def mix
    patched_with file("common/metadata") do
      push file("pod-and-service")
    end
  end
end

Kerbi::Globals.mixers << HelloWorld
```
{% endtab %}

{% tab title="common/metadata.yaml" %}
```yaml
metadata:
  annotations:
    author: person
  labels:
    app: hello-kerbi
```
{% endtab %}

{% tab title="Output" %}
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-kerbi
  namespace: demo
  annotations:
    author: person
  labels:
    app: hello-kerbi
spec:
  containers:
  - name: main
    image: nginx

---

apiVersion: v1
kind: Service
metadata:
  name: hello-kerbi
  namespace: demo
  annotations:
    author: person
  labels:
    app: hello-kerbi
spec:
  type: ClusterIP
  selector:
    app: hello-kerbi
  ports:
  - port: 80

```
{% endtab %}
{% endtabs %}

Notice how `patched_with()` method accepts the same `Hash | Array<Hash>` as `push()` that we have been using up to now. This means you can use the same methods to construct arbitrarily complex patches.&#x20;

## 4. Getting DRY & Organized

The great think about Kerbi is that it's just a normal Ruby program! You can do whatever makes sense for your project, such as [DRYing](https://en.wikipedia.org/wiki/Don't\_repeat\_yourself) up our ERB. We'll do three such things to inspire you:

1. Start using an outer namespace - **`HelloKerbi`** - to [prevent any name collisions](https://www.oreilly.com/content/ruby-cookbook-modules-and-namespaces/)
2. Create a module to store constants - **`HelloKerbi::Consts`**
3. Create a helper module we use in our template files - **`HelloKerbi::Helpers`**

{% tabs %}
{% tab title="Improved kerbifile.rb" %}
{% code title="kerbifile.rb" %}
```ruby
require_relative 'consts'
require_relative 'helpers'

module HelloKerbi
  class MainMixer < Kerbi::Mixer
    include Helpers

    def mix
      patched_with file("common/metadata") do
        push file("pod-and-service")
      end
    end
  end
end

Kerbi::Globals.mixers << HelloKerbi::MainMixer
```
{% endcode %}
{% endtab %}

{% tab title="Consts & Helpers" %}
{% code title="consts.rb" %}
```ruby
module HelloKerbi
  module Consts
    APP_NAME = "hello-kerbi"
  end
end
```
{% endcode %}

{% code title="helpers.rb" %}
```ruby
module HelloKerbi
  module Helpers
    def img2alpine(img_name)
      return img_name if img_name.include?(":")
      "#{img_name}:alpine"
    end
  end
end
```
{% endcode %}
{% endtab %}

{% tab title="Updated template File" %}
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: <%= HelloKerbi::Consts::APP_NAME %>
  namespace: <%= release_name %>
spec:
  containers:
    - name: main
      image: <%= img2alpine(values[:pod][:image]) %>

---

apiVersion: v1
kind: Service
metadata:
  name: <%= HelloKerbi::Consts::APP_NAME %>
  namespace: <%= release_name %>
spec:
  type: <%= values[:service][:type] %>
  selector:
    app: <%= HelloKerbi::Consts::APP_NAME %>
  ports:
    - port: 80
```
{% endtab %}
{% endtabs %}

## 5. Interactive Console

Another thing that sets Kerbi apart is the ability to touch your code. Using the **`kerbi console`** command, we'll open up an [**IRB session**](https://www.digitalocean.com/community/tutorials/how-to-use-irb-to-explore-ruby) do what we please with our code:

```ruby
$ kerbi console

irb(kerbi):001:0> HelloKerbi
=> HelloKerbi

irb(kerbi):002:0> values
=> {:pod=>{:image=>"nginx"}, :service=>{:type=>"ClusterIP"}}

irb(kerbi):004:0> mixer = HelloKerbi::Mixer.new(values)
=> #<HelloKerbi::Mixer:0x000056438ba4c3b8 @output=[], @release_name="default", @patch_stack=[], @values={:pod=>{:image=>"nginx"}, :service=>{:type=>"ClusterIP"}}>

irb(kerbi):005:0> mixer.run
=> {:apiVersion=>"v1", :kind=>"Pod", :metadata=>{:name=>"hello-kerbi", :namespace=>"default", :annotations=>{:author=>"xavier"}, :labels=>{:app=>"hello-kerbi"}}, :spec=>{:containers=>[{:name=>"main", :image=>"nginx:alpine"}]}}
{:apiVersion=>"v1", :kind=>"Service", :metadata=>{:name=>"hello-kerbi", :namespace=>"default", :annotations=>{:author=>"xavier"}, :labels=>{:app=>"hello-kerbi"}}, :spec=>{:type=>"ClusterIP", :selector=>{:app=>"hello-kerbi"}, :ports=>[{:port=>80}]}}
```

## 6. Writing State

You need a way to keep track of the values you use to generate your latest manifest. If you applied a templated manifest that used `--set backend.image=2` and then later `--set frontend.image=2`, then the second invokation would revert `backend.image` to its default from `values.yaml`. Big problem.

Kerbi has an [**inbuilt state mechanism**](the-state-system.md) that lets you store the values it computes as part of certain commands (`template` and `values)`, and then retrieve those values again. Kerbi uses a `ConfigMap` in your cluster to store the data. Tell Kerbi to create that `ConfigMap`:

```
$ kerbi state init demo

namespaces/demo: Created
demo/configmaps/kerbi-state-tracker: Created
```

Now let's template again, but with a new option `--write-state`: &#x20;

{% tabs %}
{% tab title="Template Command" %}
```
$ kerbi template demo \
        --set pod.image=ruby \
        --write-state @new-candidate \
        > manifest.yaml
```
{% endtab %}

{% tab title="manifest.yaml" %}
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-kerbi
  namespace: demo
  annotations:
    author: person
  labels:
    app: hello-kerbi
spec:
  containers:
  - name: main
    image: nginx:alpine

---

apiVersion: v1
kind: Service
metadata:
  name: hello-kerbi
  namespace: demo
  annotations:
    author: person
  labels:
    app: hello-kerbi
spec:
  type: ClusterIP
  selector:
    app: hello-kerbi
  ports:
  - port
```
{% endtab %}
{% endtabs %}

Let's use Kerbi's state inspection commands: `list` and `show`:

{% tabs %}
{% tab title="$ kerbi state list" %}
```
$ kerbi state list

  TAG                 MESSAGE  ASSIGNMENTS  OVERRIDES  CREATED_AT
 [cand]-brave-toner           2            1          4 seconds ago
```
{% endtab %}

{% tab title="$ kerbi state show" %}
```
$ kerbi state show @candidate

--------------------------------------------
 TAG              [cand]-brave-toner
--------------------------------------------
 MESSAGE
--------------------------------------------
 CREATED_AT       2022-04-13 10:21:50 +0100
--------------------------------------------
 VALUES           pod.image: ruby           
                  service.type: ClusterIP
--------------------------------------------
 DEFAULT_VALUES   pod.image: nginx          
                  service.type: ClusterIP
--------------------------------------------
 OVERRIDDEN_KEYS  pod
--------------------------------------------
```
{% endtab %}
{% endtabs %}

The meanings of special words like `@candidate`, `@new-candidate`, and `@latest` are covered in the [State System guide](the-state-system.md).&#x20;

## 7. Promoting and Retagging States

Now for the sake of realism, let's run `kubectl apply -f manifest`. That worked, so we feel good about these values. Let's promote our latest state:

{% tabs %}
{% tab title="$ kerbi state promote" %}
```
$ kerbi state promote @candidate

Updated state[brave-toner].tag from [cand]-brave-toner => brave-toner
```
{% endtab %}

{% tab title="$ kerbi state retag  (optional)" %}
```
$ kerbi state retag @latest 0.0.1

Updated state[0.0.1].tag from brave-toner => 0.0.1
```
{% endtab %}
{% endtabs %}

The name of our state has changed:

{% tabs %}
{% tab title="$ kerbi state list" %}
```
$ kerbi state list

 TAG    MESSAGE  ASSIGNMENTS  OVERRIDES  CREATED_AT
 0.0.1           2            1          a minute ago
```
{% endtab %}

{% tab title="$ kerbi state show" %}
```
$ kerbi state show @latest

--------------------------------------------
 TAG              0.0.1
--------------------------------------------
 MESSAGE
--------------------------------------------
 CREATED_AT       2022-04-13 10:32:55 +0100
--------------------------------------------
 VALUES           pod.image: ruby           
                  service.type: ClusterIP
--------------------------------------------
 DEFAULT_VALUES   pod.image: nginx          
                  service.type: ClusterIP
--------------------------------------------
 OVERRIDDEN_KEYS  pod
--------------------------------------------

```
{% endtab %}
{% endtabs %}

## 8. Retrieving State

It's finally time to make use of the state we saved. Let's template the manifest again, with a new value assignment, but also with the old `pod.image=ruby` assignment:

{% tabs %}
{% tab title="$ kerbi template" %}
```
$ kerbi template demo \
        --read-state @latest \
        --write-state @new-candidate \
        > manifest.yaml
```
{% endtab %}

{% tab title="manifest.yaml" %}
```
apiVersion: v1
kind: Pod
metadata:
  name: hello-kerbi
  namespace: demo
  annotations:
    author: person
  labels:
    app: hello-kerbi
spec:
  containers:
  - name: main
    image: ruby:alpine

---

apiVersion: v1
kind: Service
metadata:
  name: hello-kerbi
  namespace: demo
  annotations:
    author: person
  labels:
    app: hello-kerbi
spec:
  type: LoadBalancer
  selector:
    app: hello-kerbi
  ports:
  - port: 80
```
{% endtab %}
{% endtabs %}

We see in the manifest that the values from the old state (`pod.image=ruby`) were successfully applied which is what we wanted to do. Inspecting the state shows we have a new entry, as expected:&#x20;

```
$ kerbi state list

  TAG              MESSAGE  ASSIGNMENTS  OVERRIDES  CREATED_AT
 [cand]-warm-tap           2            2          11 seconds ago
 0.0.1                     2            1          10 minutes ago
```

## 9. In Your CD Pipeline

Putting it all together, the following shows what a simple Kubernetes deployment script using Kerbi could look like.

{% code title="my-cd-pipeline.sh" %}
```
$ kerbi state init demo --backend=ConfigMap

$ kerbi config set k8s-auth-type in-cluster

$ kerbi template demo \
        --set <however you get your vars in> \
        --read-state @latest \
        --write-state @new-candidate \
        > manifest.yaml

$ kubectl apply --dry-run=server -f manifest.yaml \
  && kerbi state promote demo @candidate \
  && kubectl apply -f manifest.yaml  
```
{% endcode %}

## 10. Managing Releases

If you start tracking more states for more apps, you'll need to start thinking about releases.

```
$ kerbi release list
 NAME  BACKEND    NAMESPACE  RESOURCE       STATES  LATEST
 bass  ConfigMap  bass       kerbi-bass-db  5       real-palsy
 tuna  ConfigMap  default    kerbi-tuna-db  2       baser-mitre
 tuna  ConfigMap  tuna       kerbi-tuna-db  1       0.0.1
```
