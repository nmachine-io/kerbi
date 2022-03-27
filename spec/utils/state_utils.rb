module Kerbi
  module Utils
    module State
      def self.kubectl_get_cm(res_name, opts={})
        kmd = "get configmap #{res_name} #{opts[:kubectl_args]}"
        Utils::Kubectl.jkmd(kmd, **opts)
      end

      def self.read_cm_data(configmap)
        json_enc_vars = configmap.dig(:data, :variables) || '{}'
        JSON.parse(json_enc_vars).deep_symbolize_keys
      end
    end
  end
end