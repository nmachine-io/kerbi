module Kerbi
  module Mixins
    module CliStateHelpers

      protected

      def entry_set
        state_backend.entry_set
      end

      def raise_unless_backend_ready
        unless state_backend.read_write_ready?
          raise Kerbi::StateBackendNotReadyError
        end
      end

      # @return [Hash{Symbol->String}]
      def read_state_values(opts={})
        if run_opts.reads_state?
          expr = run_opts.write_state_to
          entry = entry_set.find_entry_for_read(expr, opts)
          entry&.values&.deep_dup.deep_symbolize_keys || {}
        else
          {}
        end
      end

      def persist_compiled_values
        if run_opts.writes_state?
          raise_unless_backend_ready
          expr = run_opts.write_state_to
          entry = entry_set.find_or_init_entry_for_write(expr)
          patch_entry_attrs(entry)
          state_backend.save
        end
      end

      # @param [Kerbi::State::Entry] entry
      def patch_entry_attrs(entry)
        entry.values = compile_values.deep_dup
        entry.default_values = compile_default_values.deep_dup
        entry.created_at = Time.now
      end

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