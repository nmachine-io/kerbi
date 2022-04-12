# Contributing to Kerbi ♥️

First and foremost, a massive thank you if you're even reading this! This is my first ever open source project and it means the world to me that you would consider getting involved!

## Quicklinks

* [Developing Locally](#developing-locally)
* [Code of Conduct](#code-of-conduct)
* [Getting Started](#getting-started)
    * [Issues](#issues)
    * [Pull Requests](#pull-requests)
* [Getting Help](#getting-help)


## Developing Locally

After cloning the project and made a few changes, here are
the two ways I recommend for trying out your changes locally:

### Method 1: Rspec

Kerbi uses [rspec](https://rspec.info/) for testing. To run the entire suite, do:

```bash
$ bundle exec rspec -fd 
```

If you need to create a new spec file, add it in the appropriate `spec`
subdirectory. Make sure your file starts with (adjusting the relative path if necessary):

```ruby
require_relative './../spec_helper'
```

If you're using [Rubymine](https://www.jetbrains.com/ruby/) 
(which I wholeheartedly recommend), you should be able to run any test or
group of tests from inside the editor.


### Method 2: Using a play directory

Have a look at the directories inside `examples`. These work thanks to 
the `run` executable, which is always:

```ruby
#!/usr/bin/env ruby
require_relative "<my-relative-path-to>/lib/kerbi"
Kerbi::Cli::RootHandler.start(ARGV)
```   

All you need to do to create your own sandbox is create your own
directory (anywhere), add an executable like `run` above, and call it. 
It will behave exactly like calling `kerbi` except it will use the local code.

### Using Docker


You'll notice the `Dockerfile` in the project root. Create an image by running
```bash
$ docker build . -t <IMG>
$ docker push <IMG>
```

Start by running `test` on your docker image:

```bash
kubectl run kerbi-pod --context <CONTEXT> --image <IMG> -- test
```

Check out `docker-entry.sh` to find out what else you can do.

**Authenticating**. If you're running `rspec` in docker, the odds are you're
running the image as a pod in a Kubernetes cluster.

```bash
kubectl create clusterrolebinding kerbi-cluster-admin \
        --clusterrole=cluster-admin \
        --serviceaccount=default:default 
        --context <CONTEXT>
```

 

## Code of Conduct

By participating and contributing to this project, you agree to uphold our [Code of Conduct](https://github.com/nmachine-io/kerbi/blob/master/CODE_OF_CONDUCT.md).

## Contact

**Email**: [xavier@nmachine.io](xavier@nmachine.io)

**Discord**: [https://discord.gg/ntAs6TaD](https://discord.gg/ntAs6TaD)

## Getting Started

Contributions are made to this repo via Issues and Pull Requests (PRs). A few general guidelines that cover both:

- Search for existing Issues and PRs before creating your own.
- Depending on the impact, it could take a while to investigate the root cause of an issue. A friendly ping in the comment thread to the submitter or a contributor can help draw attention if your issue is blocking.

### Issues

Issues should be used to report problems with the library, request a new feature, or to discuss potential changes before a PR is created. When you create a new Issue, a template will be loaded that will guide you through collecting and providing the information we need to investigate.

If you find an Issue that addresses the problem you're having, please add your own reproduction information to the existing issue rather than creating a new one. Adding a [reaction](https://github.blog/2016-03-10-add-reactions-to-pull-requests-issues-and-comments/) can also help be indicating to our maintainers that a particular problem is affecting more than just the reporter.

### Pull Requests

PRs are always welcome and can be a quick way to get your fix or improvement slated for the next release. In general, PRs should:

- Only fix/add the functionality in question **OR** address wide-spread whitespace/style issues, not both.
- Add unit or integration tests for fixed or changed functionality (if a test suite already exists).
- Address a single concern.

For changes that address core functionality or would require breaking changes (e.g. a major release), it's best to open an Issue to discuss your proposal first. This is not required but can save time creating and reviewing changes.

In general, we follow the ["fork-and-pull" Git workflow](https://github.com/susam/gitpr)

1. Fork the repository to your own Github account
2. Clone the project to your machine
3. Create a branch locally with a succinct but descriptive name
4. Commit changes to the branch
5. Following any formatting and testing guidelines specific to this repo
6. Push changes to your fork
7. Open a PR in our repository and follow the PR template so that we can efficiently review the changes.
