module Kerbi
  module Consts

    module OptionKeys
      PROJECT_ROOT = "project-root"
      REVISION_TAG = "revision"
      RELEASE_NAME = "release-name"

      OUTPUT_FMT = "output-format"
      INLINE_ASSIGNMENT = "inline-value"
      LOAD_DEFAULT_VALUES = "load-defaults"
      VALUE_FNAMES = "values-file"

      RUBY_VER = "ruby-version"
      VERBOSE = "verbose"
      PRE_CONFIRM = "confirm"

      STATE_BACKEND_TYPE = "state-backend"
      READ_STATE = "read-state"
      STRICT_READ_STATE = "strict-read"
      WRITE_STATE = "write-state"
      NAMESPACE = "namespace"
      WRITE_STATE_MESSAGE = "message"

      K8S_AUTH_TYPE = "k8s-auth-type"
      KUBE_CONFIG_PATH = "kube-config-path"
      KUBE_CONFIG_CONTEXT = "kube-config-context"
      KUBE_ACCESS_TOKEN = "k8s-access-token"
      K8S_USERNAME = "k8s-username"
      K8S_PASSWORD = "k8s-password"

      LEGAL_CONFIG_FILE_KEYS = [
        LOAD_DEFAULT_VALUES,
        OUTPUT_FMT,
        STATE_BACKEND_TYPE,
        K8S_AUTH_TYPE,
        KUBE_CONFIG_PATH,
        KUBE_CONFIG_CONTEXT,
        KUBE_ACCESS_TOKEN,
      ]
    end

    module OptionDefaults
      BASE = {
        OptionKeys::LOAD_DEFAULT_VALUES => true,
        OptionKeys::INLINE_ASSIGNMENT => [],
        OptionKeys::VALUE_FNAMES => [],
        OptionKeys::OUTPUT_FMT => "yaml",
        OptionKeys::STATE_BACKEND_TYPE => "configmap",
        OptionKeys::K8S_AUTH_TYPE => "kube-config"
      }.freeze

      LIST_STATE = BASE.merge(
        OptionKeys::OUTPUT_FMT => "table"
      ).freeze

      LIST_RELEASE = BASE.merge(
        OptionKeys::OUTPUT_FMT => "table"
      ).freeze
    end

    module OptionSchemas

      PROJECT_ROOT = {
        key: OptionKeys::PROJECT_ROOT,
        desc: "Project root. An abs path, a rel path, "\
              "or remote (/foo, foo, @foo/bar)",
        aliases: "-p"
      }

      REVISION_TAG = {
        key: OptionKeys::REVISION_TAG,
        desc: "Use this version of the Kerbi templating "\
              "engine (given by [PROJECT_URI]).",
        aliases: "-p"
      }

      K8S_AUTH_TYPE = {
        key: OptionKeys::K8S_AUTH_TYPE,
        desc: "Kubernetes cluster authentication type. Uses " \
              "kube-config if unspecified.",
        enum: %w[kube-config in-cluster token]
      }.freeze

      KUBE_CONFIG_PATH = {
        key: OptionKeys::KUBE_CONFIG_PATH,
        desc: "Path to your kube-config file. Uses " \
               "~/.kube/config if unspecified."
      }.freeze

      KUBE_CONFIG_CONTEXT = {
        key: OptionKeys::KUBE_CONFIG_CONTEXT,
        desc: "Context to use in your kube config. "\
              "Uses current context if unspecified."
      }.freeze

      K8S_USERNAME = {
        key: OptionKeys::K8S_USERNAME,
        desc: "Kubernetes auth username for basic password auth"
      }.freeze

      K8S_PASSWORD = {
        key: OptionKeys::K8S_PASSWORD,
        desc: "Kubernetes auth password for basic password auth"
      }.freeze

      LOAD_DEFAULT_VALUES = {
        key: OptionKeys::LOAD_DEFAULT_VALUES,
        desc: "Whether or not to automatically load values.yaml.",
        type: "boolean",
        default: true
      }.freeze

      KUBE_ACCESS_TOKEN = {
        key: OptionKeys::KUBE_ACCESS_TOKEN,
        desc: "Kubernetes auth bearer token for token auth"
      }.freeze

      RELEASE_NAME = {
        key: OptionKeys::RELEASE_NAME,
        desc: "Release name for commands where state I/O is optional"
      }

      STATE_BACKEND_TYPE = {
        key: OptionKeys::STATE_BACKEND_TYPE,
        desc: "Type of persistent store to read/write this release's state.",
        enum: %w[configmap secret]
      }.freeze

      OUTPUT_FMT = {
        key: OptionKeys::OUTPUT_FMT,
        aliases: "-o",
        desc: "In what format resulting data should be printed",
        enum: %w[yaml json table]
      }.freeze

      INLINE_ASSIGNMENT = {
        key: OptionKeys::INLINE_ASSIGNMENT,
        aliases: "--set",
        desc: "Merge value from this assignment, "\
              "e.g --set x.y=foo. Multiple --set are allowed.",
        repeatable: true
      }.freeze

      READ_STATE = {
        key: OptionKeys::READ_STATE,
        desc: "Merge values from state with this tag.",
      }.freeze

      STRICT_READ_STATE = {
        key: OptionKeys::STRICT_READ_STATE,
        desc: "Makes read-state operations fail if the " \
                "state does not exist for the given tag",
      }.freeze

      WRITE_STATE = {
        key: OptionKeys::WRITE_STATE,
        desc: "Write compiled values into new or existing state record" \
              "with this tag."
      }.freeze

      NAMESPACE = {
        key: OptionKeys::NAMESPACE,
        aliases: "-n",
        desc: "Use this Kubernetes namespace instead of [RELEASE_NAME] "\
              "for state I/O."
      }.freeze

      VALUE_FNAMES = {
        key: OptionKeys::VALUE_FNAMES,
        aliases: "-f",
        desc: "Merge all values read from this file. Multiple " \
              "-f are allowed.",
        repeatable: true
      }.freeze

      RUBY_VER = {
        key: OptionKeys::RUBY_VER,
        desc: "Ruby version semver for autogenerated " \
              "Gemfile."
      }.freeze

      VERBOSE = {
        key: OptionKeys::VERBOSE,
        desc: "Run in verbose mode",
        type: "boolean"
      }.freeze

      PRE_CONFIRM = {
        key: OptionKeys::PRE_CONFIRM,
        desc: "Skip any CLI confirmation prompts",
        type: "boolean"
      }.freeze

      KUBERNETES_OPTIONS = [
        NAMESPACE,
        STATE_BACKEND_TYPE,
        READ_STATE,
        WRITE_STATE,
        K8S_AUTH_TYPE,
        KUBE_CONFIG_PATH,
        KUBE_CONFIG_CONTEXT,
        KUBE_ACCESS_TOKEN
      ].freeze

      VALUES_OPTIONS = [
        VALUE_FNAMES,
        INLINE_ASSIGNMENT,
        LOAD_DEFAULT_VALUES,
      ].freeze
    end

    module CommandSchemas

      VALUES_SUPER = {
        name: "values",
        desc: "Command group for values actions (see $ kerbi values help)"
      }.freeze

      PROJECT_SUPER = {
        name: "project",
        desc: "Command group for project actions (see $ kerbi project help)"
      }.freeze

      STATE_SUPER = {
        name: "state",
        desc: "Command group for state actions (see $ kerbi state help)"
      }.freeze

      RELEASE_SUPER = {
        name: "release",
        desc: "Command group for release actions (see $ kerbi release help)"
      }.freeze

      CONFIG_SUPER = {
        name: "config",
        desc: "Command group for config actions (see $ kerbi config help)"
      }.freeze

      TEMPLATE = {
        name: "template [RELEASE_NAME] [PROJECT_URI]",
        desc: "Templates to YAML/JSON, using [RELEASE_NAME] for state I/O",
        options: [
          OptionSchemas::PROJECT_ROOT,
          OptionSchemas::OUTPUT_FMT,
          *OptionSchemas::VALUES_OPTIONS,
          *OptionSchemas::KUBERNETES_OPTIONS
        ]
      }.freeze

      CONSOLE = {
        name: "console",
        desc: "Opens an IRB console so you can play with your mixers",
        options: [
          OptionSchemas::PROJECT_ROOT,
          OptionSchemas::VALUE_FNAMES,
          OptionSchemas::INLINE_ASSIGNMENT
        ]
      }.freeze

      VERSION = {
        name: "version",
        desc: "Prints the version of this RubyGem",
        options: []
      }.freeze

      NEW_PROJECT = {
        name: "new",
        desc: "Create a new directory with boilerplate files",
        options: [
          OptionSchemas::RUBY_VER,
          OptionSchemas::VERBOSE
        ]
      }.freeze

      RELEASE_STATUS = {
        name: "status [RELEASE_NAME]",
        desc: "Check readiness of release's ConfigMap/Secret backend.",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
          OptionSchemas::VERBOSE
        ]
      }.freeze

      RELEASE_LIST = {
        name: "list",
        desc: "Lists all known Kerbi releases by scanning cluster" \
              " ConfigMaps/Secrets",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
          OptionSchemas::VERBOSE
        ]
      }.freeze

      RELEASE_DELETE = {
        name: "delete [RELEASE_NAME]",
        desc: "Delete the ConfigMap/Secret storing states for"\
              " this release",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
          OptionSchemas::PRE_CONFIRM
        ]
      }.freeze

      LIST_STATE = {
        name: "list [RELEASE_NAME]",
        desc: "Print all recorded states for [RELEASE_NAME]",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
          OptionSchemas::OUTPUT_FMT
        ],
        defaults: OptionDefaults::LIST_STATE
      }.freeze

      INIT_RELEASE = {
        name: "init [RELEASE_NAME]",
        desc: "Provision the resources for persisting the state",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
          OptionSchemas::VERBOSE
        ]
      }.freeze

      SHOW_STATE = {
        name: "show [RELEASE_NAME] [TAG]",
        desc: "Print summary of state identified by [TAG]",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
          OptionSchemas::OUTPUT_FMT
        ],
        defaults: OptionDefaults::LIST_STATE
      }.freeze

      RETAG_STATE = {
        name: "retag [RELEASE_NAME] [OLD_TAG] [NEW_TAG]",
        desc: "Updates entry's tag given by [OLD_TAG] to [NEW_TAG]",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
          OptionSchemas::OUTPUT_FMT
        ],
        defaults: OptionDefaults::LIST_STATE
      }.freeze

      PROMOTE_STATE = {
        name: "promote [RELEASE_NAME] [TAG]",
        desc: "Removes the [cand]- prefix from the given entry,
               removing its candidate status.",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
        ],
        defaults: OptionDefaults::LIST_STATE
      }.freeze

      DEMOTE_STATE = {
        name: "promote [RELEASE_NAME] [TAG]",
        desc: "Adds the [cand]- prefix from the given entry,
               giving it candidate status.",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
        ],
        defaults: OptionDefaults::LIST_STATE
      }.freeze

      DELETE_STATE = {
        name: "delete [RELEASE_NAME] [TAG]",
        desc: "Deletes the state entry given by [TAG]",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
        ]
      }.freeze

      SET_STATE_ATTR = {
        name: "set [RELEASE_NAME] [TAG] [ATTR_NAME] [NEW_VALUE]",
        desc: "Updates state entry [TAG], attribute "\
              "[ATTR_NAME] to value [NEW_VALUE]",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
        ]
      }.freeze

      PRUNE_CANDIDATES_STATE = {
        name: "prune-candidates [RELEASE_NAME]",
        desc: "Deletes all state entries flagged as candidates",
        options: [
          *OptionSchemas::KUBERNETES_OPTIONS,
        ]
      }.freeze

      SHOW_VERSION = {
        name: "version",
        desc: "Print the kerbi gem's version.",
        options: []
      }.freeze

      SHOW_VALUES = {
        name: "show",
        desc: "Prints the final compiled values for the given sources",
        options: [
          OptionSchemas::OUTPUT_FMT,
          OptionSchemas::PROJECT_ROOT,
          OptionSchemas::RELEASE_NAME,
          *OptionSchemas::VALUES_OPTIONS,
          *OptionSchemas::KUBERNETES_OPTIONS
        ]
      }.freeze

      CONFIG_LOCATION = {
        name: "location",
        desc: "Prints out filesystem path for global Kerbi config"
      }.freeze

      CONFIG_SET = {
        name: "set [KEY] [VALUE]",
        desc: "Writes an x=y configuration to the global kerbi config"
      }.freeze

      CONFIG_GET = {
        name: "get [KEY]",
        desc: "Prints out the value of KEY as loaded into the options"
      }.freeze

      CONFIG_SHOW = {
        name: "show",
        desc: "Prints out the value of KEY as loaded into the options",
        options: [
          OptionSchemas::OUTPUT_FMT
        ]
      }.freeze

      CONFIG_RESET = {
        name: "reset",
        desc: "Resets the config file to its default state",
        options: []
      }.freeze
    end
  end
end