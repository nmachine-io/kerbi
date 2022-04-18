# The Templating API

If you're using Kerbi, you probably enjoy Ruby in YAML, a.k.a ERB. This guide covers the most useful methods available to you inside your `.yaml.erb` files.

Most of the methods here come from [**`Kerbi::Mixins::Mixer`**](https://github.com/nmachine-io/kerbi/blob/main/lib/mixins/mixer.rb), which is documented [here](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixins/Mixer).

### Public and Custom Mixer API methods

In addition to the methods listed in the next sections, you have access to:

* Every public method from the [Mixer API](the-mixer-api.md) (e.g `values`,  `file()`, etc...), except `#push()`
* Any custom methods you define in your Mixer subclass, including those included from modules

See both in action below with **`file()`** and **`ingress_enabled?()`**:

{% tabs %}
{% tab title="ingress.yaml.erb" %}
```yaml
<% if ingress_enabled? %>
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations: <%= embed(file("ingress-annotations")) %>
spec:
  #...
<% end %>
```
{% endtab %}

{% tab title="ingress-annotations.yaml" %}
```yaml
nginx.ingress.kubernetes.io/rewrite-target: /
nginx.ingress.kubernetes.io/custom-http-errors: "404,415"
nginx.ingress.kubernetes.io/cors-expose-headers: "*, X-CustomResponseHeader"
```
{% endtab %}

{% tab title="Output" %}
Running `kerbi template default --set ingress.enabled=true`:



```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: "/"
    nginx.ingress.kubernetes.io/custom-http-errors: '404,415'
    nginx.ingress.kubernetes.io/cors-expose-headers: "*, X-CustomResponseHeader"
spec: 
```
{% endtab %}

{% tab title="kerbifile.rb" %}
```ruby
class TemplatingExample < Kerbi::Mixer
  def mix
    push file("ingress")
  end
  
  def ingress_enabled?
    values.dig(:ingress, :enabled).present?
  end
end
```
{% endtab %}
{% endtabs %}

### The [`b64enc()`](the-templating-api.md#public-and-custom-mixer-api-methods) method

Encodes a string as its Base64 representation, as it is often necessary with [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/):

{% tabs %}
{% tab title="Template" %}
```yaml
kind: Secret
metadata:
  name: postgres-pw
data:
  password: <%= b64enc(values.dig(:web, :db, :pw) || "unsafe") %>
```
{% endtab %}

{% tab title="Output" %}
```yaml
kind: Secret
metadata:
  name: postgres-pw
data:
  password: dW5zYWZl
```
{% endtab %}
{% endtabs %}

### The [`b64dec()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixins/Mixer#b64dec-instance\_method) method

Decodes a string from its Base64 representation:

{% tabs %}
{% tab title="Template" %}
```yaml
kind: Secret
metadata:
  name: postgres-pw
data:
  password: <%= b64dec("dW5zYWZl") %>
```
{% endtab %}

{% tab title="Output" %}
```yaml
kind: Secret
metadata:
  name: postgres-pw
data:
  password: unsafe
```
{% endtab %}
{% endtabs %}

### The [`embed()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixins/Mixer#embed-instance\_method) and [`embed_array()`](https://www.rubydoc.info/gems/kerbi/1.1.47/Kerbi/Mixins/Mixer#embed\_array-instance\_method) methods

The `embed()` and `embed_array()` methods convert, respectively, a `Hash` and an `Array<Hash>`, into an appropriately indented `String` that can be embedded into a YAML file.&#x20;

{% tabs %}
{% tab title="Template" %}
```yaml
apiVersion: networking.k8s.io/v1
kind: Pod
metadata:
  name: minimal-ingress
  annotations: <%= embed({foo: "bar"}) %>
spec: 
  restartPolicy: Never
  containers: <%= embed_array(dir("containers")) %>
```
{% endtab %}

{% tab title="Output" %}
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    foo: bar
spec: 
```
{% endtab %}
{% endtabs %}

#### About Indentation

Both methods assume that what you're trying to embed should appear as far "right" as possible. If this is not what you need, you can pass the optional **`indent: Integer`** option. If the indent is wrong, e.g it is too small, YAML parsing will raise an exception and templating will fail.

#### Embedding items into a List&#x20;

If you have a YAML-defined list and need to add individual items, the best known way to do this (although this is not ideal), is to call `embed_array()` with an explicit `indent: Integer` that you find by counting, or more realistically by trial and error.

{% tabs %}
{% tab title="Template" %}
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: embed-item
  namespace: <%= release_name %>
spec:
  containers:
    - name: nginx
      image: nginx
      <%= embed_array(
            [{name: "traefik", image: "traefik"}],
            indent: 4
       ) %>
```
{% endtab %}

{% tab title="Output" %}
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: embed-item
  namespace: aasd
spec:
  containers:
  - name: nginx
    image: nginx
  - name: traefik
    image: traefik
```
{% endtab %}
{% endtabs %}



###