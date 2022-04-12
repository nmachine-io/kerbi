module Kerbi
  module CodeGen
    class ProjectGenerator

      ERB_EXT = ".erb"
      BOILER_REL_PATH = "/../code-gen/new-project"

      ##
      # Serves as both the new project's dir name and the mixer's _module name
      attr_accessor :project_name

      ##
      # Mostly for testing, uses this dir as root instead of Dir.pwd
      attr_accessor :root_dir

      ##
      # Optional ruby version to use in the Gemfile
      attr_accessor :ruby_version

      ##
      # Print as you go?
      attr_accessor :verbose

      ##
      # Set accessors, no other side effects.
      def initialize(params={})
        self.project_name = params[:project_name]
        self.root_dir = params[:root_dir]
        self.ruby_version = params[:ruby_version]
        self.verbose = params[:verbose]
      end

      ##
      # Creates a new directory, writes new interpolated files to it.
      def run
        return false unless create_dir
        self.class.boiler_file_abs_paths.each do |src_name, src_path|
          process_file(src_name, src_path)
        end
        true
      end

      def create_dir
        begin
          Dir.mkdir(new_dir_path)
          print_created('Created project at', new_dir_path)
          true
        rescue Errno::EEXIST
          message = "Error dir already exists: #{new_dir_path}"
          $stderr.puts message.colorize(:red)
        end
      end

      ## Root function for processing a single file, e.g reading its
      # original un-interpolated form, interpolating it, and finally
      # writing the new content to destination directory.
      # @param [String] src_file_name src file name w/o path e.g Gemfile.erb
      # @param [String] src_file_path src file name including abs path
      def process_file(src_file_name, src_file_path)
        data = generate_data
        new_file_content = self.class.interpolate_file(src_file_path, data)
        new_file_path = mk_dest_path(src_file_name)
        File.write(new_file_path, new_file_content)
        print_file_processed(src_file_name)
      end

      def print_file_processed(src_file_name)
        pretty_fname = "#{self.class.src_to_dest_file_name(src_file_name)}"
        pretty_name = "#{project_name}/#{pretty_fname}"
        self.print_created("Created file", pretty_name)
      end

      #noinspection RubyResolve
      def print_created(bold_part, colored_part)
        return unless verbose
        puts "#{bold_part.bold} #{colored_part.colorize(:blue)}"
      end

      ##
      # Returns a dict with all the key value assignments the ERBs
      # need to do their work.
      # @return [Hash{Symbol->String}] data bundle for interpolation
      def generate_data
        module_name = project_name.underscore.classify
        version = ruby_version || RUBY_VERSION
        {
          user_module_name: module_name,
          ruby_version: version
        }
      end

      ##
      # Generates absolute path of destination file based on filename
      # of source file. E.g Gemfile.erb -> /home/foo/Gemfile
      # @param [String] src_file_name src file name w/o path e.g Gemfile.erb
      # @return [String] E.g Gemfile.erb -> /home/foo/Gemfile
      def mk_dest_path(src_file_name)
        new_fname = self.class.src_to_dest_file_name(src_file_name)
        "#{new_dir_path}/#{new_fname}"
      end

      def self.src_to_dest_file_name(src_file_name)
        src_file_name[0..-(ERB_EXT.length + 1)]
      end

      ## Returns the absolute path of the new project directory
      # based on the constructor arguments
      # @return [String] e.g /home/john/hello-kerbi
      def new_dir_path
        "#{root_dir || Dir.pwd}/#{project_name}"
      end

      def self.boiler_file_abs_paths
        boiler_dir_path = "#{__dir__}#{BOILER_REL_PATH}"

        is_boiler = ->(fname) { fname.end_with?(ERB_EXT) }
        to_abs = ->(fname) { "#{boiler_dir_path}/#{fname}" }

        boiler_fnames = Dir.entries(boiler_dir_path)
        actual_fnames = boiler_fnames.select(&is_boiler)
        Hash[actual_fnames.map { |f| [f, to_abs[f]] }]
      end

      def self.interpolate_file(src_path, data)
        contents = File.read(src_path)
        binding.local_variable_set(:data, data)
        ERB.new(contents).result(binding)
      end
    end
  end
end