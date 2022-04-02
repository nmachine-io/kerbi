module Kerbi
  module Cli
    class ProjectHandler < BaseHandler

      thor_meta Kerbi::Consts::CommandSchemas::NEW_PROJECT
      def new_project(project_name)
        generator = Kerbi::CodeGen::ProjectGenerator.new(
          project_name: project_name,
          ruby_version: run_opts.ruby_version,
          verbose: true
        )
        success = generator.run
        exit(success)
      end
    end
  end
end
