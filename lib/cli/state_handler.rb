module Kerbi
  module Cli
    class StateHandler < BaseHandler
      include Kerbi::Mixins::StatePrinting

      thor_meta Kerbi::Consts::CommandSchemas::TEST_STATE
      def test_connection
        backend = make_state_backend
        backend.test_connection(verbose: cli_opts.verbose?)
      end

      thor_meta Kerbi::Consts::CommandSchemas::LIST_STATE
      def list
        backend = make_state_backend
        print_state_list(backend.read_entries)
      end

      protected

      def make_state_backend
        if cli_opts.state_backend_type == 'configmap'
          auth_bundle = make_k8s_auth_bundle
          Kerbi::State::ConfigMapBackend.new(
            auth_bundle,
            cli_opts.cluster_namespace
          )
        end
      end

      def make_k8s_auth_bundle
        case cli_opts.k8s_auth_type
        when "kube-config"
          Kerbi::Utils::K8sAuth.kube_config_bundle(
            path: cli_opts.kube_config_path,
            name: cli_opts.kube_context_name
          )
        when "basic"
          Kerbi::Utils::K8sAuth.basic_auth_bundle(
            username: cli_opts.k8s_auth_username,
            password: cli_opts.k8s_auth_password
          )
        when "token"
          Kerbi::Utils::K8sAuth.token_auth_bundle(
            bearer_token: cli_opts.k8s_auth_token,
          )
        when "in-cluster"
          Kerbi::Utils::K8sAuth.in_cluster_auth_bundle
        else
          raise "Bad k8s connect type '#{cli_opts.k8s_auth_type}'"
        end
      end

    end
  end
end
