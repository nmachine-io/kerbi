module Kerbi
  module State

    ##
    # Treats a Kubernetes configmap in a namespace as a
    # persistent store for state entries. Reads and writes
    # to the configmap.
    class ConfigMapBackend < Kerbi::State::BaseBackend
      include Kerbi::Mixins::CmBackendTesting

      attr_reader :auth_bundle
      attr_reader :namespace

      # @param [Hash] auth_bundle generated by Kerbi::Utils::K8sAuth
      # @param [String] release_name Kubernetes namespace where configmap lives
      def initialize(auth_bundle, release_name, namespace)
        @auth_bundle = auth_bundle.freeze
        @release_name = release_name.freeze
        @namespace = (namespace || @release_name).freeze
      end

      ##
      # Checks for the namespace and configmap, creating along
      # the way if missing. Does not raise if already exists.
      # @param [Hash] opts for things like verbose
      def provision_missing_resources(**opts)
        create_namespace unless (ns_existed = namespace_exists?)
        echo_init("namespaces/#{namespace}", ns_existed, opts)

        create_resource unless (cm_existed = resource_exists?)
        echo_init("configmaps/#{namespace}/#{cm_name}", cm_existed, opts)
      end

      ##
      # Creates the configmap with 0 entries.
      def create_resource
        apply_resource(template_resource([]))
      end

      ##
      # Creates the configmap given an exact dict representation
      # of its contents. This method doesn't actually get used outside
      # of rspec, but it's super useful there so keeping for time being.
      # @param [Hash] resource_desc
      def apply_resource(resource_desc, mode: 'create')
        if mode == 'create'
          #noinspection RubyResolve
          client("v1").create_config_map(resource_desc)
        elsif mode == 'update'
          #noinspection RubyResolve
          client("v1").update_config_map(resource_desc)
        else
          raise "What kind of sick mode is #{mode}?"
        end
      end

      ##
      # Outputs the dict representation of the configmap, templated
      # with the given entries.
      # @param [Array<Kerbi::State::Entry>] entries
      # @return [Hash]
      def template_resource(entries)
        values = {
          consts::ENTRIES_ATTR => entries.map(&:to_h),
          namespace: namespace,
          cm_name: cm_name
        }
        Kerbi::State::ConfigMapMixer.new(values).run.first
      end

      ##
      # Creates the required namespace resource for this configmap
      # in the cluster.
      def create_namespace
        values = { namespace: namespace }
        dict = Kerbi::State::NamespaceMixer.new(values).run.first
        #noinspection RubyResolve
        client("v1").create_namespace(dict)
      end

      def resource_name
        cm_name
      end

      def resource_signature
        "configmaps/#{namespace}/#{resource_name}"
      end

      protected

      ##
      # Reads the configmap from Kubernetes, returns its dict representation.
      def load_resource
        #noinspection RubyResolve
        client("v1").get_config_map(cm_name, namespace).to_h
      end

      ##
      # Reads the configmap from Kubernetes, returns its dict representation.
      def delete_resource
        #noinspection RubyResolve
        client("v1").delete_config_map(cm_name, namespace)
      end

      ##
      # Templates the updated version of the configmap given the entries
      # in memory, and uses the new dict to overwrite the last configmap
      # in the cluster.
      def update_resource
        new_resource = template_resource(entries)
        #noinspection RubyResolve
        client("v1").update_config_map(new_resource)
      end

      ##
      # Deserializes the list of entries in the configmap. Calls
      # #resources, which is memoized, so may trigger a cluster read.
      # @return [Array<Hash>] entries
      def read_entries
        str_entries = resource[:data][consts::ENTRIES_ATTR]
        JSON.parse(str_entries)
      end

      ## Creates an instance of Kubeclient::Client given
      # the auth_bundle in the state, and a Kubernetes API name
      # like appsV1 (defaults to "v1" if not passed).
      # @return [Kubeclient::Client]
      def client(api_name="v1")
        self.class.make_client(auth_bundle, api_name)
      end

      def consts
        Kerbi::State::Consts
      end

      def cm_name
        self.class.mk_cm_name(release_name)
      end

      def self.releases(auth_bundle)
        client = make_client(auth_bundle, "v1")
        res_dicts = client.get_config_maps.map(&:to_h).select do |res_dict|
          name = res_dict.dig(:metadata, :name)
          name =~ Kerbi::State::Consts::CM_REGEX
        end

        res_dicts.map do |res_dict|
          name, namespace = res_dict[:metadata].values_at(:name, :namespace)
          release = name.match(Kerbi::State::Consts::CM_REGEX)[1]
          self.new(auth_bundle, release, namespace)
        end
      end

      def self.mk_cm_name(release_name)
        "kerbi-#{release_name}-db"
      end

      def self.make_client(auth_bundle, api_name)
        Kubeclient::Client.new(
          auth_bundle[:endpoint],
          api_name,
          **auth_bundle[:options]
        )
      end

      def self.type_signature
        "ConfigMap"
      end

    end
  end
end