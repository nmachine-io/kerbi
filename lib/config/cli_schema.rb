module Kerbi
  module Consts

    module OptionKeys
      OUTPUT_FMT = "output"
      INLINE_ASSIGNMENT = "inline-value"
      VALUE_FNAMES = "values-file"
      USE_STATE_VALUES = "use-state-values"
      RUBY_VER = "ruby-version"
      VERBOSE = "verbose"
    end

    module OptionSchemas
      OUTPUT_FMT = {
        key: OptionKeys::OUTPUT_FMT,
        desc: "Specify YAML or JSON. Defaults to YAML",
        enum: %w[yaml json]
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

