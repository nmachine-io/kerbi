module Kerbi
  module Utils

    ##
    # ALl *_bundle methods return a custom-schema hash
    # that is to be used to create a Kubeclient::Client instance.
    # See its constructor docs to understand.
    # Underlying lib credit: https://github.com/ManageIQ/kubeclient
    module K8sAuth

      ##
      # Auth using config/credentials from a local kube context
      # entry.
      # See https://github.com/ManageIQ/kubeclient#kubeclientconfig
      def self.kube_config_bundle(path: nil, name: nil)
        path = path || default_kube_config_path
        config = Kubeclient::Config.read(path)
        context = config.context(name)

        {
          endpoint: context.api_endpoint,
          options: {
            ssl_options: context.ssl_options,
            auth_options: context.auth_options
          }
        }
      end

      ##
      # Basic username password auth.
      # See https://github.com/ManageIQ/kubeclient#authentication
      def self.basic_auth_bundle(username:, password:)
        {
          endpoint: "https://localhost:8443/api",
          options: {
            auth_options: {
              username: username,
              password: password
            }
          }
        }
      end

      ##
      # Auth using explicit bearer token for each request.
      # See https://github.com/ManageIQ/kubeclient#authentication
      def self.token_auth_bundle(bearer_token:)
        {
          endpoint: "https://localhost:8443/api",
          options: {
            auth_options: {
              bearer_token: bearer_token
            }
          }
        }
      end

      ##
      # Auth if kerbi is inside a Kubernetes cluster. Uses default
      # credentials in pod's filesystem. Likely requires extra
      # RBAC resources for that service account to exist, e.g
      # a few Roles/ClusterRoles and RoleBinding/ClusterRoleBindings
      # in order for CRUD methods to actually work.
      # See https://github.com/ManageIQ/kubeclient#middleware
      def self.in_cluster_auth_bundle
        token_path = '/var/run/secrets/kubernetes.io/serviceaccount/token'
        ca_crt_path = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
        auth_options = { bearer_token_file: token_path }

        ssl_options = {}
        ssl_options[:ca_file] = ca_crt_path if File.exist?(ca_crt_path)

        {
          endpoint: "https://kubernetes.default.svc",
          options: {
            auth_options: auth_options,
            ssl_options: ssl_options
          }
        }
      end

      def self.default_kube_config_path
        ENV['KUBECONFIG'] || "#{Dir.home}/.kube/config"
      end
    end
  end
end