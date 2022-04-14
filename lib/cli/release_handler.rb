module Kerbi
  module Cli
    class ReleaseHandler < BaseHandler
      cmd_meta Kerbi::Consts::CommandSchemas::INIT_RELEASE
      # @param [String] release_name refers to a Kubernetes namespace
      def init(release_name)
        mem_release_name(release_name)
        state_backend.provision_missing_resources(verbose: run_opts.verbose?)
        ns_key = Kerbi::Consts::OptionSchemas::NAMESPACE
        Kerbi::ConfigFile.patch({ns_key => release_name})
      end

      cmd_meta Kerbi::Consts::CommandSchemas::RELEASE_STATUS
      def status(release_name)
        mem_release_name(release_name)
        backend = state_backend
        backend.test_connection(verbose: run_opts.verbose?)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::RELEASE_LIST
      def list
        prep_opts(Kerbi::Consts::OptionDefaults::LIST_STATE)
        auth_bundle = Kerbi::Utils::Cli.make_k8s_auth_bundle(run_opts)
        backends = Kerbi::State::ConfigMapBackend.releases(auth_bundle)
        echo_data(backends, serializer: Kerbi::Cli::ReleaseSerializer)
      end

    end
  end
end
