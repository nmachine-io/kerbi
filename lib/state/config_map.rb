module Kerbi
  module StateBackend
    class ConfigMap < Kerbi::StateBackend::Base
      include Kerbi::Mixins::ResourceStateBackendHelpers

      attr_reader :auth_bundle
      attr_reader :client
      attr_reader :namespace

      def initialize(auth_bundle, namespace)
        @auth_bundle = auth_bundle.freeze
        @namespace = namespace.freeze
      end

      def namespace_exists?
      end

      def resource_exists?
      end

      def read_resource
        read_resource! rescue nil
      end

      def read_resource!
        raise "asdas"
      end

      # @return [Array<Kerbi::StateBackend::Entry>]
      def list()

      end

      def read(version)

      end

      protected

      def make_client(bundle, api_name)
        Kubeclient::Client.new(
          bundle[:endpoint],
          api_name,
          **bundle[:options]
        )
      end

    end
  end
end