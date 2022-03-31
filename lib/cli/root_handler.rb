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

      cmd_schemas = Kerbi::Consts::CommandSchemas

      thor_meta cmd_schemas::TEMPLATE
      # @param [String] release_name helm-like Kubernetes release name
      # @param [String] path root dir from which to search for kerbifile.rb
      def template(release_name, path)
        utils::Cli.load_kerbifile(path)
        values = self.compile_values
        mixer_classes = Kerbi::Globals.mixers
        res_dicts = utils::Cli.run_mixers(mixer_classes, values, release_name)
        print_dicts(res_dicts)
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

      thor_sub_meta cmd_schemas::VALUES_SUPER, ValuesHandler
      thor_sub_meta cmd_schemas::PROJECT_SUPER, ProjectHandler
      thor_sub_meta cmd_schemas::STATE_SUPER, StateHandler
    end
  end
end
