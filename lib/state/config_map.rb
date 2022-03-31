module Kerbi
  module State
    class ConfigMapBackend < Kerbi::State::BaseBackend
      include Kerbi::Mixins::ResourceStateBackendHelpers

      attr_reader :auth_bundle
      attr_reader :namespace

      def initialize(auth_bundle, namespace)
        @auth_bundle = auth_bundle.freeze
        @namespace = namespace.freeze
      end

      def namespace_exists?
      end

      def resource_exists?
      end

      # @return [Array<Kerbi::State::Entry>] entries
      def read_entries
        result_dict = load_resource
        json_entries = result_dict[:data][:entries]
        JSON.parse(json_entries).first
      end

      def apply_resource(resource_desc)
        client!("v1").create_config_map(resource_desc)
      end

      # @param [Array<Kerbi::State::Entry>] entries
      def template_resource(entries)
        consts = Kerbi::State::Consts
        values = { consts::ENTRIES_ATTR => entries }
        Kerbi::State::ConfigMapMixer.new(
          values,
          release_name: namespace
        ).run.first
      end

      def load_resource
        name = Kerbi::State::Consts::RESOURCE_NAME
        client!("v1").get_config_map(name, namespace).to_h
      end

      # @return [Array<Kerbi::State::Entry>]
      def list()

      end

      protected

      def client!(api_name="v1")
        Kubeclient::Client.new(
          auth_bundle[:endpoint],
          api_name,
          **auth_bundle[:options]
        )
      end

    end
  end
end