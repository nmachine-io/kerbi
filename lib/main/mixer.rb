module Kerbi
  class Mixer
    include Kerbi::Mixins::Mixer

    ##
    # Values hash available to subclasses
    # @return [Immutable::Hash] symbol-keyed hash
    attr_reader :values

    ##
    # Release name available for templating
    # @return [String] symbol-keyed hash
    attr_reader :release_name

    ##
    # Array of res-hashes being aggregated
    # @return [Array<Hash>] list of hashes
    attr_reader :output

    ##
    # Array of patches to be applied to results
    # @return [Array<Hash>] list of hashes
    attr_accessor :patch_stack

    ##
    # Constructor
    # @param [Hash] values the values tree that will be accessible to the subclass
    def initialize(values, opts={})
      @output = []
      @release_name = opts[:release_name] || "default"
      @patch_stack = []
      @values = self.class.compute_own_values_subtree(
        values,
        opts[:overwrite_values_root]
      )
    end

    ##
    # Where users should return a hash or
    # an array of hashes representing Kubernetes resources
    # @yield [bucket] Exec context in which hashes are collected into one bucket
    # @yieldparam [Kerbi::ResBucket] g Bucket object with essential methods
    # @yieldreturn [Array<Hash>] array of hashes representing Kubernetes resources
    # @return [Array<Hash>] array of hashes representing Kubernetes resources
    def run
      begin
        self.mix
      rescue Error => e
        puts "Exception below caused by mixer #{self.class.name}"
        raise e
      end
      self.output
    end

    def mix
    end

    ##
    # Registers a dict or an array of dicts that will part of the
    # mixers's final output, which is an Array<Hash>.
    # @param [Hash | Array<Hash>] dict the hash to be added
    def push(dicts)
      final_list = Utils::Mixing.sanitize_res_dict_list(dicts)
      self.output.append(*final_list)
    end

    ##
    # Normalizes, sanitizes and filters a dict or an array of
    # dicts.
    # @param [Hash | Array<Hash>] dict the hash to be added
    def dicts(dict, **opts)
      output = Utils::Mixing.clean_and_filter_dicts(dict, **opts)
      should_patch = opts[:no_patch].blank?
      should_patch ? apply_patch_context(output) : output
    end
    alias_method :dict, :dicts

    ##
    # Loads a YAML/JSON/ERB file, parses it, interpolates it,
    # and returns processed and filtered list of dicts via #dicts.
    # @param [String] fname with or without extension, relative to self
    # @param [Hash] opts filtering and other options for #dicts
    # @return [Array<Hash>] processed dicts read from file
    def file(fname, **opts)
      output = Utils::Mixing.yaml_file_to_dicts(
        self.class.resolve_file_name(fname),
        **opts.merge({src_binding: binding})
      )
      dicts(output)
    end

    # @param [String] fname
    # @param [Hash] opts filtering and other options for #dicts
    # @return [Array]
    def dir(fname, **opts)
      output = Utils::Mixing.yamls_in_dir_to_dicts(
        self.class.pwd,
        resolve_file_name(fname),
        **opts
      )
      dicts(output)
    end

    ##
    # Run 'helm template' on Helm project, parse the output into dicts,
    # return processed and filtered list via #dicts.
    # @param [String] chart_id using format 'jetstack/cert-manager'
    # @param [Hash] opts filtering and other options for #dicts
    # @return [Array<Hash>] processed and filtered dicts
    def chart(chart_id, **opts)
      release = opts[:release] || release_name
      helm_output = Utils::Helm.template(release, chart_id, **opts)
      dicts(helm_output)
    end

    ##
    # Run another mixer given by klass, return processed and
    # filtered list via #dicts.
    # @param [Class<Kerbi::Mixer>] klass other mixer's class
    # @param [Hash] opts filtering and other options for #dicts
    # @return [Array<Hash>] processed and filtered dicts
    def mixer(klass, **opts)
      force_subtree = opts.delete(:values)
      mixer_inst = klass.new(
        force_subtree.nil? ? values : force_subtree,
        release_name: release_name,
        overwrite_values_subtree: !force_subtree.nil?
      )
      output = mixer_inst.run
      dicts(output)
    end

    ##
    # Any x-to-dict statements (e.g #dicts, #dir, #chart) executed
    # in the &block passed to this method will have their return values
    # deep merged with the dict(s) passed.
    # @param [Array<Hash>|Hash] dict
    # @param [Proc] block
    # @return [Array<Hash>, Hash]
    def patched_with(dict, &block)
      new_patches = extract_patches(dict)
      patch_stack.push(new_patches)
      yield(block)
      patch_stack.pop
    end

    private

    def extract_patches(obj)
      (obj.is_a?(Hash) ? [obj] : obj).map(&:deep_dup)
    end

    def apply_patch_context(output)
      return output if patch_stack.blank?
      output.map do |res|
        patch_stack.flatten.inject(res) do |whole, patch|
          whole.deep_merge(patch)
        end
      end
    end

    ##
    # Coerces filename of unknown format to an absolute path
    # @param [String] fname simplified or absolute path of file
    # @return [String] a variation of the filename that exists
    ##
    # Convenience instance method for accessing class level pwd
    # @return [String] the subclass' pwd as defined by the user

    class << self

      ##
      # Pass a deep key that will be used to dig into the values
      # dict the mixer gets upon initialization. For example if
      # deep_key is "x", then if the mixer is initialized with
      # values as x: {y: 'z'}, then its final values attribute
      # will be {y: 'z'}.
      def values_root(deep_key)
        @vals_root_deep_key = deep_key
      end

      def compute_own_values_subtree(values_root, override)
        self.compute_values_subtree(
          values_root,
          override ? nil : @vals_root_deep_key
        )
      end

      ##
      # Given a values_root dict and a deep key (e.g "x.y.z"), outputs
      # a frozen, deep-cloned, subtree corresponding to the deep
      # key's position in the values_root.
      # @param [Hash] values_root dict from which to extract subtree
      # @param [String] deep_key key in dict in "x.y.z" format
      # @return [Hash] frozen and deep-cloned subtree
      def compute_values_subtree(values_root, deep_key)
        subtree = values_root.deep_dup
        if deep_key.present?
          deep_key_parts = deep_key.split(".")
          subtree = subtree.dig(*deep_key_parts)
        end
        subtree.freeze
      end

      ## Resolves a user-given short name for a file to interpolate,
      # like 'pod', 'pod.yaml', into an absolute file path.
      # @param [String] fname_expr e.g 'pod', 'pod.yaml'
      # @return [?String]
      def resolve_file_name(fname_expr)
        dir = self.pwd
        Kerbi::Utils::Misc.real_files_for(
          fname_expr,
          "#{fname_expr}.yaml",
          "#{fname_expr}.yaml.erb",
          "#{dir}/#{fname_expr}",
          "#{dir}/#{fname_expr}.yaml",
          "#{dir}/#{fname_expr}.yaml.erb"
        ).first
      end

      ##
      # Sets the absolute path of the directory where
      # yamls used by this Gen can be found, usually "__dir__"
      # @param [String] dirname absolute path of the directory
      # @return [void]
      def locate_self(dirname)
        @dir_location = dirname
      end

      ##
      # Returns the value set by locate_self
      # @return [String] the subclass' pwd as defined by the user
      def pwd
        @dir_location
      end
    end

  end
end