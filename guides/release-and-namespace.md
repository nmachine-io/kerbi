# Release & Namespace

One seemingly small but important difference between Kerbi and Helm is the treatment of namespaces and "releases".&#x20;

In short, Kerbi thinks, by default, of one Kubernetes namespaces as synonymous with the concept of "one release", e.g 1 app = 1 namespace = its "release name".

## Where it Matters

Until now, we've been invoking `$ kerbi template foo` without thinking much about `foo` other  than knowing the internal variable `release_name` for templating, e.g:

```
apiVersion: v1
kind: Pod
metadata:
  namespace: <%= release_name %>
```

## Why are either necessary?



## Default Behavior

