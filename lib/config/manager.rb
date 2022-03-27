module Kerbi
  module Config
    class Manager
      attr_reader :bundle

      def initialize
        # TODO load me from filesystem
        @bundle = {
          tmp_helm_values_path: '/tmp/kerbi-helm-vals.yaml',
          helm_exec: "helm"
        }
      end

      def self.inst
        # TODO create ~/.config/kerbi etc...
        @_instance ||= self.new
      end

      def self.tmp_helm_values_path
        inst.bundle[:tmp_helm_values_path]
      end

      def self.helm_exec
        inst.bundle[:helm_exec]
      end

      def self.tmp_helm_values_path=(val)
        inst.bundle[:tmp_helm_values_path] = val
      end

      def self.helm_exec=(val)
        inst.bundle[:helm_exec] = val
      end
    end
  end
end
