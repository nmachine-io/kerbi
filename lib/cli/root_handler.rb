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

      def self.start(*args, **kwargs)
        begin
          super
        rescue Kerbi::Error => e
          #noinspection RubyResolve
          puts e.to_s.colorize(:red).bold
        end
      end

      cmd_schemas = Kerbi::Consts::CommandSchemas

      thor_meta cmd_schemas::TEMPLATE
      # @param [String] release_name helm-like Kubernetes release name
      # @param [String] path root dir from which to search for kerbifile.rb
      def template(release_name, path)
        utils::Cli.load_kerbifile(path)
        values = compile_values
        persist_compiled_values
        mixer_classes = Kerbi::Globals.mixers
        res_dicts = utils::Cli.run_mixers(mixer_classes, values, release_name)
        echo_data(res_dicts, coerce_type: "Array")
      end

      thor_meta cmd_schemas::CONSOLE
      def console
        utils::Cli.load_kerbifile(".")
        values = self.compile_values
        ARGV.clear
        IRB.setup(eval("__FILE__"), argv: [])
        workspace = IRB::WorkSpace.new(Console.new(values))
        IRB::Irb.new(workspace).run(IRB.conf)
      end

      thor_meta cmd_schemas::SHOW_VERSION
      def version
        puts "1"
      end

      thor_sub_meta cmd_schemas::VALUES_SUPER, ValuesHandler
      thor_sub_meta cmd_schemas::PROJECT_SUPER, ProjectHandler
      thor_sub_meta cmd_schemas::STATE_SUPER, StateHandler
      thor_sub_meta cmd_schemas::CONFIG_SUPER, ConfigHandler
    end
  end
end
