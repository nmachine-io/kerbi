---
description: Running your templating logic as it was at different points in time.
---

# Revisions

At this point in our discussion of the [storage and retrieval of states](the-state-system.md), we have implicitly assumed that the templating logic (i.e your source code) stayed the same across states. This is obviously unrealistic, so we need to introduce the concept of a revision.

{% hint style="warning" %}
**Work in progress.**

The revision system is in its infancy. The following is meant to prepare you for what is to come if you are considering using Kerbi for your applications.
{% endhint %}

## What is a Revision?

Conceptually, a revision is an instantiation of your templating logic at one point in time.&#x20;

**How does it work?** You use the CLI to "publish" a revision to a special registry, very similar to how you would a Ruby gem (a Rust crate, a Python lib, etc...), and that special registry serves your revision over HTTP as a JSON API.

```
$ kerbi revision push 1.0.1
```

After a few seconds, anyone can access your Kerbi project's logic over the air:

```json
$ curl -X api.kerbi.dev/hooli/nucleus/1.0.1/template | jq
{"data": [{"apiVersion": "v1", "kind": "Pod", "etc": "..."}]}

$ curl api.kerbi.dev/hooli/nucleus/1.0.1/values | jq
{"data": {"backend": {"image": "foo:latest"} } }
```

You can then use the revision in Kerbi:

```
$ kerbi template nucleus . --revision 1.0.1
```

Or generally:

```
$ kerbi template nucleus hooli/nucleus --revision 1.0.1
```

Or from your mixers:

```ruby
class DemoMixer < Kerbi::Mixer
  def mix
    push remote_mixer(project_uri, "1.0.1")
  end
end

Kerbi::Globals.org = "hooli"
Kerbi::Globals.project = "nucleus"
```
