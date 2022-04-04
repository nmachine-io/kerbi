module Kerbi
  module Mixins
    module CliStateHelpers

      protected

      def raise_unless_backend_ready
        unless state_backend.read_write_ready?
          raise Kerbi::StateBackendNotReadyError
        end
      end

      def persist_compiled_values
        if run_opts.writes_state?
          raise_unless_backend_ready
          entry_cls = Kerbi::State::Entry
          expr = run_opts.write_state_to
          if (entry = find_entry(expr))
            state_backend.update_entry(entry, {})
          elsif entry_cls.auto_inc_expr?(expr)
          else
          end
        end
      end

      def create_entry(q_expr)
      end

      def read_state_values
        if run_opts.reads_state?
          entry = find_entry(run_opts.read_state_from)
          entry&.values || {}
        else
          {}
        end
      end

      # @return [?Kerbi::State::Entry]
      def find_entry(expr)
        backend = state_backend

        if Entry.latest_expr?(expr)
          backend.entries.find(&:latest?)
        elsif Entry.candidate_expr?(expr)
          backend.entries.find(&:candidate?)
        else
          entry = backend.find_entry(expr)
          raise Kerbi::BadEntryQueryForWrite unless entry
          entry
        end
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