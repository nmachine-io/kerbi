module Kerbi

  class Console
    attr_reader :values

    def initialize(values)
      @values = values
    end

    def to_s
      "kerbi"
    end
  end

  module Cli
    ##
    # Top level CLI command handler with Thor.
    class RootHandler < BaseHandler

      ##
      # Two things happen here:
      # 1. Kerbi::Globals.reset is necessary for testing, because memory
      # is not flushed.
      def self.start(*args, **kwargs)
        begin
          Kerbi::Globals.reset
          super
        rescue Kerbi::Error => e
          #noinspection RubyResolve
          puts e.to_s.colorize(:red).bold
        end
      end

      cmd_meta Kerbi::Consts::CommandSchemas::TEMPLATE
      # @param [String] release_name helm-like Kubernetes release name
      def template(release_name)
        utils::Cli.load_kerbifile(run_opts.project_root)
        values = compile_values
        persist_compiled_values
        mixer_classes = Kerbi::Globals.mixers
        res_dicts = utils::Cli.run_mixers(mixer_classes, values, release_name)
        echo_data(res_dicts, coerce_type: "Array")
      end

      cmd_meta Kerbi::Consts::CommandSchemas::CONSOLE
      def console
        utils::Cli.load_kerbifile(run_opts.project_root)
        values = compile_values
        ARGV.clear
        IRB.setup(eval("__FILE__"), argv: [])
        workspace = IRB::WorkSpace.new(Console.new(values))
        IRB::Irb.new(workspace).run(IRB.conf)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::SHOW_VERSION
      def version
        puts "1"
      end

      sub_cmd_meta Kerbi::Consts::CommandSchemas::VALUES_SUPER, ValuesHandler
      sub_cmd_meta Kerbi::Consts::CommandSchemas::PROJECT_SUPER, ProjectHandler
      sub_cmd_meta Kerbi::Consts::CommandSchemas::RELEASE_SUPER, ReleaseHandler
      sub_cmd_meta Kerbi::Consts::CommandSchemas::STATE_SUPER, StateHandler
      sub_cmd_meta Kerbi::Consts::CommandSchemas::CONFIG_SUPER, ConfigHandler
    end
  end
end
