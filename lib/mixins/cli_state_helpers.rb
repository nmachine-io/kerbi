module Kerbi
  module Mixins
    module CliStateHelpers

      protected

      ##
      # Convenience method that returns the state backend's entry set.
      # @return [Kerbi::State::EntrySet]
      def entry_set
        state_backend.entry_set
      end

      ##
      # For commands that need a working state backend,
      # ask the backend if it is operational, and raise otherwise.
      def raise_unless_backend_ready
        unless state_backend.read_write_ready?
          raise Kerbi::StateBackendNotReadyError
        end
      end

      ##
      # Convenience method for invoking #find_entry_for_read
      # on the state backend's entry-set.
      # @return [Kerbi::State::Entry]
      def find_readable_entry(tag_expr)
        entry_set.find_entry_for_read(tag_expr)
      end

      ##
      # Convenience method for updating a state entry's created_at
      # and then persisting the new list of entries via the state backend.
      # Also optionally pretty prints changes.
      # @param [Kerbi::State::Entry] entry
      def touch_and_save_entry(entry, changes={})
        entry.created_at = Time.now
        state_backend.save
        if changes && (change = changes.first)
          key, old_value = change
          new_value = entry.send(key) rescue "ERR"
          name = "state[#{entry.tag}].#{key}"
          change_str = "from #{old_value} => #{new_value}"
          puts "Updated #{name} #{change_str}".colorize(:green)
        end
      end

      ##
      # Given a tag by read-state [TAG], find the corresponding
      # state entry and return its values dict.
      #
      # If the state entry is NOT found, an empty dict is returned,
      # unless the strict-read option is also passed, in which
      # case it raises a fatal exception.
      # @return [Hash{Symbol->String}]
      def read_state_values
        if run_opts.reads_state?
          expr = run_opts.read_state_from
          begin
            entry = entry_set.find_entry_for_read(expr)
            entry.values.deep_dup.deep_symbolize_keys
          rescue Kerbi::StateNotFoundError => e
            raise e if run_opts.reads_state_strictly?
            {}
          end
        else
          {}
        end
      end

      ##
      # Given a tag by write-state [TAG], find or create a state entry
      # and assign its values and default_values to the respective
      # just values and default_values just compiled.
      def persist_compiled_values
        if run_opts.writes_state?
          raise_unless_backend_ready
          expr = run_opts.write_state_to
          entry = entry_set.find_or_init_entry_for_write(expr)

          entry.values = compile_values.deep_dup
          entry.default_values = compile_default_values.deep_dup
          entry.created_at = Time.now

          state_backend.save
        end
      end

      ##
      # Given the state-backend parameter or config value,
      # generate an instance of the corresponding backend
      # class.
      # @return [Kerbi::State::Backend]
      def generate_state_backend(namespace=nil)
        if run_opts.state_backend_type == 'configmap'
          auth_bundle = make_k8s_auth_bundle
          Kerbi::State::ConfigMapBackend.new(
            auth_bundle,
            namespace || run_opts.cluster_namespace
          )
        end
      end

      ##
      # Given the various Kubernetes authentication options and
      # configs, generates a Hash with the necessary data/schema
      # to pass onto the internal k8s authentication logic.
      #
      # This method only delegates. Actual work done is done here at:
      # Kerbi::Utils::K8sAuth.
      # @return [Hash] auth bundle for the k8s authentication logic.
      def make_k8s_auth_bundle
        case run_opts.k8s_auth_type
        when "kube-config"
          Kerbi::Utils::K8sAuth.kube_config_bundle(
            path: run_opts.kube_config_path,
            name: run_opts.kube_context_name
          )
        when "basic"
          Kerbi::Utils::K8sAuth.basic_auth_bundle(
            username: run_opts.k8s_auth_username,
            password: run_opts.k8s_auth_password
          )
        when "token"
          Kerbi::Utils::K8sAuth.token_auth_bundle(
            bearer_token: run_opts.k8s_auth_token,
            )
        when "in-cluster"
          Kerbi::Utils::K8sAuth.in_cluster_auth_bundle
        else
          raise "Bad k8s connect type '#{run_opts.k8s_auth_type}'"
        end
      end
    end
  end
end