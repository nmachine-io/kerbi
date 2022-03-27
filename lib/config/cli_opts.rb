module Kerbi

  ##
  # Convenience accessor struct for getting values from
  # the CLI args.
  class CliOpts

    attr_reader :options

    def initialize(options={})
      @options = options.deep_dup
    end

    def output_format
      value = options[consts::OUTPUT_FMT]
      value || "yaml"
    end

    def outputs_yaml?
      self.output_format == 'yaml'
    end

    def outputs_json?
      self.output_format == 'json'
    end

    def ruby_version
      options[consts::RUBY_VER]
    end

    def fname_exprs
      options[consts::VALUE_FNAMES] || []
    end

    def inline_val_exprs
      options[consts::INLINE_ASSIGNMENT] || []
    end

    def use_state?
      options[consts::USE_STATE_VALUES].present?
    end

    private

    def consts
      Kerbi::Consts::OptionKeys
    end

  end
end