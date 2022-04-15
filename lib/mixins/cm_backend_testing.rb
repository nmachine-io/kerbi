module Kerbi
  module Mixins
    module CmBackendTesting

      # @return [TrueClass, FalseClass]
      def namespace_exists?
        begin
          !!client("v1").get_namespace(namespace)
        rescue Kubeclient::ResourceNotFoundError
          false
        end
      end

      def resource_exists?
        begin
          !!resource
        rescue Kubeclient::ResourceNotFoundError
          false
        end
      end

      def read_write_ready?
        namespace_exists? && \
        resource_exists? && \
        data_readable?
      end

      def test_connection(options={})
        exceptions = []

        schema = [
          {
            method: :client,
            message: "1. Create Kubernetes client"
          },
          {
            method: :test_list_namespaces,
            message: "2. List cluster namespaces"
          },
          {
            method: :test_target_ns_exists,
            message: "3. Target namespace #{namespace} exists"
          },
          {
            method: :load_resource,
            message: "4. Resource #{namespace}/cm/#{cm_name} exists"
          },
          {
            method: :entries,
            message: "5. Data from resource is readable"
          }
        ]

        schema.each do |spec|
          begin
            self.send(spec[:method])
            puts_outcome(spec[:message], true)
          rescue StandardError => e
            puts_outcome(spec[:message], false)
            exceptions << { exception: e, test: spec[:message] }
          end
        end

        if exceptions.any? && options[:verbose]
          #noinspection RubyResolve
          puts "\n---EXCEPTIONS---\n".colorize(:red).bold
          exceptions.each do |exc|
            base = "[#{exc[:test]}] #{exc[:exception]}"
            #noinspection RubyResolve
            puts base.to_s.colorize(:red).bold
            puts exc[:exception].backtrace
            puts "\n\n"
          end
        end
      end

      def test_list_namespaces
        #noinspection RubyResolve
        client("v1").get_namespaces.any?
      end

      def test_target_ns_exists
        client.get_namespace namespace
      end

      def data_readable?
        entries.is_a?(Array)
      end

      #noinspection RubyResolve
      def puts_outcome(msg, result)
        outcome_str = result.present? ? "Success" : "Failure"
        color = result.present? ? :green : :red
        outcome_str = outcome_str.colorize(color)
        puts "#{msg}: #{outcome_str}".bold
      end

      def echo_init(msg, result, options={})
        unless options[:quiet].present?
          outcome_str = result.present? ? "Already existed" : "Created"
          color = result.present? ? :green : :blue
          outcome_str = outcome_str.colorize(color)
          #noinspection RubyResolve
          puts "#{msg}: #{outcome_str}".bold
        end
      end
    end
  end
end