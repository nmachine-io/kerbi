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

      def provision_missing_resources(opts={})
        create_namespace unless (ns_existed = namespace_exists?)
        puts_init("namespaces/#{namespace}", ns_existed, opts)

        create_resource unless (cm_existed = resource_exists?)
        puts_init("#{namespace}/configmaps/#{cm_name}", cm_existed, opts)
      end

      def create_resource
        apply_resource(template_resource([]))
      end

      # @param [Array<Kerbi::State::Entry>] entries
      def update(entries=nil)
        entries = self.entries if entries.nil?
        new_resource = template_resource(entries)
        #noinspection RubyResolve
        client("v1").update_config_map(new_resource)
      end

      # @param [Hash] resource_desc
      def apply_resource(resource_desc)
        #noinspection RubyResolve
        client("v1").create_config_map(resource_desc)
      end

      # @param [Array<Kerbi::State::Entry>] entries
      def template_resource(entries)
        values = { consts::ENTRIES_ATTR => entries.map(&:serialize) }
        opts = { release_name: namespace }
        Kerbi::State::ConfigMapMixer.new(values, **opts).run.first
      end

      def create_namespace
        opts = { release_name: namespace }
        dict = Kerbi::State::NamespaceMixer.new({}, **opts).run.first
        #noinspection RubyResolve
        client("v1").create_namespace(dict)
      end

      # @return [Array<Kerbi::State::Entry>]
      def list()
      end

      protected

      def load_resource
        #noinspection RubyResolve
        client("v1").get_config_map(cm_name, namespace).to_h
      end

      # @return [Array<Kerbi::State::Entry>] entries
      def read_entries
        str_entries = resource[:data][:entries]
        dict_entries = JSON.parse(str_entries)
        entries = dict_entries.map { |h| Entry.from_dict(h) }
        self.class.post_process_entries(entries)
      end

      def client(api_name="v1")
        Kubeclient::Client.new(
          auth_bundle[:endpoint],
          api_name,
          **auth_bundle[:options]
        )
      end

      def consts
        Kerbi::State::Consts
      end

      def cm_name
        consts::RESOURCE_NAME
      end
    end
  end
end