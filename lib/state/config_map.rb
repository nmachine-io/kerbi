module Kerbi
  module StateBackend
    class ConfigMap < Kerbi::StateBackend::Base

      attr_reader :auth_bundle

      attr_reader :client

      def initialize(auth_bundle)
        super
        @auth_bundle = auth_bundle.freeze
      end

      def test_connection(options={})
        exceptions = []
        client = nil
        begin
          client = make_client(auth_bundle, "v1")
          @client = client
        rescue Exception => e
          exceptions << e
        end
        puts "Create Kubernetes client: #{success_col(client)}"
      end

      def success_col(thing)
        message = thing.present? ? "Success" : "Failure"
        color = thing.present? ? :green : :red
        message.colorize(color)
      end

      def namespace_exists?
      end

      def resource_exists?
      end

      def read_resource
        read_resource! rescue nil
      end

      def read_resource!
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