module Kerbi
  module State
    class ConfigMapBackend < Kerbi::State::BaseBackend
      include Kerbi::Mixins::CmBackendTesting

      attr_reader :auth_bundle
      attr_reader :namespace

      def initialize(auth_bundle, namespace)
        @auth_bundle = auth_bundle.freeze
        @namespace = namespace.freeze
      end

      def create_resource
        apply_resource([])
      end

      def namespace_exists?
      end

      def resource_exists?
      end

      def add_entry
      end

      # @return [Array<Kerbi::State::Entry>] entries
      def read_entries
        str_entries = load_resource[:data][:entries]
        json_entries = JSON.parse(str_entries)
        entries = json_entries.map {|e| Kerbi::State::Entry.from_dict(e) }
        self.class.post_process_entries(entries)
      end

      def apply_resource(resource_desc)
        #noinspection RubyResolve
        client!("v1").create_config_map(resource_desc)
      end

      # @param [Array<Kerbi::State::Entry>] entries
      def template_resource(entries)
        consts = Kerbi::State::Consts
        values = { consts::ENTRIES_ATTR => entries.map(&:serialize) }
        opts = { release_name: namespace }
        Kerbi::State::ConfigMapMixer.new(values, **opts).run.first
      end

      def load_resource
        name = Kerbi::State::Consts::RESOURCE_NAME
        #noinspection RubyResolve
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