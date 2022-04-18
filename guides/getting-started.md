---
description: Install Kerbi, create a project, and generate your first manifest.
---

# Getting Started

Kerbi is a Ruby [gem](https://www.ruby-lang.org/en/libraries/). It comes with code, which you use for your kerbi projects, and an executable, which is a convenient command line interface. Here, we'll install the gem and generate a project.

## 1. Install the Gem

Start by installing the kerbi gem globally:

```bash
$ gem install kerbi
```

You can now run the `kerbi` executable from anywhere:

```bash
$ kerbi
Commands:
  kerbi help [COMMAND]                       # Describe available commands or one specific command
  kerbi project                              # Command group for project actions: new, info
  kerbi template [KERBIFILE] [RELEASE_NAME]  # Runs mixers for RELEASE_NAME
  kerbi values                               # Command group for values actions: show, get
```

## 2. Generate a Boilerplate Project

Move to your desired workspace and run kerbi's boilerplate project generator command:

```
$ kerbi project new hello-kerbi
```

Inspect the newly created project, and optionally, run the bundler:

```
$ cd hello-kerbi
$ bundle install
```

## 3. Run Basic Commands

Get familiar with the command line API by running the two most basic commands, starting with `template`:

```
$ kerbi template hello . 
```

And then `values show` to see compiled values in action:

```
$ kerbi values show --set foo-bar
```



##