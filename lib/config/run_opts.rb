module Kerbi

  ##
  # Convenience accessor struct for getting values from
  # the CLI args.
  class RunOpts

    attr_reader :options

    # @param [Hash{Symbol, Object}] cli_opts CLI args as a hash via Thor
    # @param [Hash{Symbol, Object}] defaults contextual defaults (per cmd)
    # @return [Kerbi::RunOpts]
    def initialize(cli_opts, defaults)
      @options = defaults.deep_dup.
        merge(Kerbi::ConfigFile.read.deep_dup).
        merge(cli_opts.deep_dup).
        freeze
    end

    # @return [String]
    def output_format
      value = options[consts::OUTPUT_FMT]
      value || default
    end

    # @return [TrueClass, FalseClass]
    def output_yaml?
      self.output_format == 'yaml'
    end

    # @return [TrueClass, FalseClass]
    def output_table?
      self.output_format == 'table'
    end

    # @return [TrueClass, FalseClass]
    def output_json?
      self.output_format == 'json'
    end

    # @return [String]
    def ruby_version
      options[consts::RUBY_VER]
    end

    # @return [Array<String>]
    def fname_exprs
      options[consts::VALUE_FNAMES]
    end

    # @return [Array<String>]
    def inline_val_exprs
      options[consts::INLINE_ASSIGNMENT]
    end

    # @return [TrueClass, FalseClass]
    def load_defaults?
      options[consts::LOAD_DEFAULT_VALUES].present?
    end

    # @return [String]
    def read_state_from
      options[consts::READ_STATE].presence
    end

    # @return [String]
    def write_state_to
      options[consts::WRITE_STATE].presence
    end

    # @return [TrueClass, FalseClass]
    def verbose?
      options[consts::VERBOSE].present?
    end

    # @return [TrueClass, FalseClass]
    def reads_state?
      read_state_from.present?
    end

    # @return [TrueClass, FalseClass]
    def writes_state?
      write_state_to.present?
    end

    # @return [String]
    def k8s_auth_type
      options[consts::K8S_AUTH_TYPE]
    end

    # @return [String]
    def kube_config_path
      options[consts::KUBE_CONFIG_PATH]
    end

    # @return [String]
    def kube_context_name
      options[consts::KUBE_CONFIG_CONTEXT]
    end

    # @return [String]
    def cluster_namespace
      options[consts::NAMESPACE]
    end

    # @return [String]
    def state_backend_type
      options[consts::STATE_BACKEND_TYPE]
    end

    # @return [String]
    def k8s_auth_username
      options[consts::K8S_USERNAME]
    end

    # @return [String]
    def k8s_auth_password
      options[consts::K8S_PASSWORD]
    end

    # @return [String]
    def k8s_auth_token
      options[consts::K8S_TOKEN]
    end

    # @return [String]
    def write_state_msg
      options[consts::WRITE_STATE_MESSAGE]
    end

    private

    # @return [Module<Kerbi::Consts::OptionKeys>]
    def consts
      Kerbi::Consts::OptionKeys
    end

  end
end