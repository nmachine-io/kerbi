module Kerbi
  module Cli

    ##
    # Top level CLI command handler with Thor.
    class RootHandler < BaseHandler

      cmd_schemas = Kerbi::Consts::CommandSchemas

      thor_meta cmd_schemas::TEMPLATE
      # @param [String] path root dir from which to search for kerbifile.rb
      # @param [String] release_name helm-like Kubernetes release name
      def template(path, release_name)
        utils::Cli.load_kerbifile(path)
        values = self.compile_values
        mixer_classes = Kerbi::Globals.mixers
        res_dicts = utils::Cli.run_mixers(mixer_classes, values, release_name)
        print_dicts(res_dicts)
      end

      thor_meta cmd_schemas::CONSOLE
      def console
        utils::Cli.load_kerbifile(".")
        ARGV.clear
        IRB.start("#{Dir.pwd}/kerbifile.rb")
      end

      thor_sub_meta cmd_schemas::VALUES_SUPER, ValuesHandler
      thor_sub_meta cmd_schemas::PROJECT_SUPER, ProjectHandler
    end
  end
end
