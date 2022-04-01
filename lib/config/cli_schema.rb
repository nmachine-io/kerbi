module Kerbi
  module Consts

    module OptionKeys
      OUTPUT_FMT = "output"
      INLINE_ASSIGNMENT = "inline-value"
      VALUE_FNAMES = "values-file"
      USE_STATE_VALUES = "use-state-values"
      RUBY_VER = "ruby-version"
      VERBOSE = "verbose"
      READ_STATE = "read-state"
      WRITE_STATE = "write-state"
      NAMESPACE = "namespace"

      STATE_BACKEND_TYPE = "state-backend"

      K8S_AUTH_TYPE = "auth-type"
      KUBE_CONFIG_PATH = "kube-config-path"
      KUBE_CONFIG_CONTEXT = "kube-config-context"
      K8S_USERNAME = "username"
      K8S_PASSWORD = "password"
      K8S_TOKEN = "token"
    end

    module OptionSchemas
      K8S_AUTH_TYPE = {
        key: OptionKeys::K8S_AUTH_TYPE,
        desc: "Strategy for connecting to target cluster (defaults to kube-config)",
        enum: %w[kube-config in-cluster basic token]
      }

      KUBE_CONFIG_PATH = {
        key: OptionKeys::KUBE_CONFIG_PATH,
        desc: "path to your kube-config file, defaults to ~/.kube/config"
      }

      KUBE_CONFIG_CONTEXT = {
        key: OptionKeys::KUBE_CONFIG_CONTEXT,
        desc: "context to use in your kube config,
defaults to $(kubectl config current-context)"
      }

      K8S_USERNAME = {
        key: OptionKeys::K8S_USERNAME,
        desc: "Kubernetes auth username for basic password auth"
      }

      K8S_PASSWORD = {
        key: OptionKeys::K8S_PASSWORD,
        desc: "Kubernetes auth password for basic password auth"
      }

      K8S_TOKEN = {
        key: OptionKeys::K8S_TOKEN,
        desc: "Kubernetes auth bearer token for token auth"
      }

      OUTPUT_FMT = {
        key: OptionKeys::OUTPUT_FMT,
        aliases: "-o",
        desc: "Specify YAML, JSON, or table",
        enum: %w[yaml json table]
      }

      USE_STATE_VALUES = {
        key: OptionKeys::USE_STATE_VALUES,
        desc: "If true, merges in values loaded from state ConfigMap",
        type: "boolean"
      }

      INLINE_ASSIGNMENT = {
        key: OptionKeys::INLINE_ASSIGNMENT,
        aliases: "--set",
        desc: "An inline variable assignment, e.g --set x.y=foo --set x.z=bar",
        repeatable: true
      }

      READ_STATE = {
        key: OptionKeys::READ_STATE,
        desc: "merge values from given state record into final values",
      }

      WRITE_STATE = {
        key: OptionKeys::WRITE_STATE,
        desc: "write compiled values into given state record"
      }

      NAMESPACE = {
        key: OptionKeys::NAMESPACE,
        desc: "for state operations, tell kerbi that the state
               configmap/secret is in this namespace"
      }

      VALUE_FNAMES = {
        key: OptionKeys::VALUE_FNAMES,
        aliases: "-f",
        desc: "Name of a values file to be loaded.",
        repeatable: true
      }

      RUBY_VER = {
        key: OptionKeys::RUBY_VER,
        desc: "Specify ruby version for Gemfile in a new project"
      }

      VERBOSE = {
        key: OptionKeys::VERBOSE,
        desc: "Run in verbose mode",
        enum: %w[true false]
      }

      KUBERNETES_OPTIONS = [
        K8S_AUTH_TYPE,
        KUBE_CONFIG_PATH,
        KUBE_CONFIG_CONTEXT,
        NAMESPACE
      ]

    end

    module CommandSchemas

      VALUES_SUPER = {
        name: "values",
        desc: "Command group for values actions: show, get"
      }

      PROJECT_SUPER = {
        name: "project",
        desc: "Command group for project actions: new, info"
      }

      STATE_SUPER = {
        name: "state",
        desc: "Command group for state actions: test, list, show"
      }

      TEMPLATE = {
        name: "template [KERBIFILE] [RELEASE_NAME]",
        desc: "Runs mixers for RELEASE_NAME",
        options: [
          OptionSchemas::OUTPUT_FMT,
          OptionSchemas::VALUE_FNAMES,
          OptionSchemas::INLINE_ASSIGNMENT
        ]
      }

      CONSOLE = {
        name: "console",
        desc: "Opens an IRB console so you can play with your mixers",
        options: [
          OptionSchemas::VALUE_FNAMES,
          OptionSchemas::INLINE_ASSIGNMENT
        ]
      }

      NEW_PROJECT = {
        name: "new",
        desc: "Create a new directory with boilerplate files",
        options: [
          OptionSchemas::RUBY_VER,
          OptionSchemas::VERBOSE
        ]
      }

      TEST_STATE = {
        name: "test_connection",
        desc: "Tries to read the state tracker, prints true/false",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
          OptionSchemas::VERBOSE
        ]
      }

      LIST_STATE = {
        name: "list",
        desc: "Print all recorded states for this namespace",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
          OptionSchemas::OUTPUT_FMT
        ]
      }

      SHOW_STATE = {
        name: "show [TAG]",
        desc: "Print summary of state identified by [TAG]",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS
        ]
      }

      SHOW_VALUES = {
        name: "show",
        desc: "Print out loaded values as YAML",
        options: [
          OptionSchemas::OUTPUT_FMT,
          OptionSchemas::VALUE_FNAMES,
          OptionSchemas::INLINE_ASSIGNMENT
        ]
      }
    end
  end
end

