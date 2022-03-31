module Kerbi
  module Mixins
    module ResourceStateBackendHelpers

      def test_connection(options={})
        exceptions = []

        schema = [
          {
            method: :test_create_client,
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
            method: :read_resource!,
            message: "3. Resource #{namespace}/cm/#{'state'} exists"
          }
        ]

        schema.each do |spec|
          begin
            send(spec[:method])
            puts_outcome(spec[:message], true)
          rescue Exception => e
            puts_outcome(spec[:message], false)
            exceptions << { exception: e, test: spec[:message] }
          end
        end

        if exceptions.any? && options[:verbose]
          puts "\n---EXCEPTIONS---\n".colorize(:red).bold
          exceptions.each do |exc|
            puts "[#{exc[:test]}] #{exc[:exception]}".to_s.colorize(:red).bold
            puts exc[:exception].backtrace
            puts "\n\n"
          end
        end
      end

      def test_create_client
        client = make_client(auth_bundle, "v1")
        @client = client
      end

      def test_list_namespaces
        client.get_namespaces.any?
      end

      def test_target_ns_exists
        client.get_namespace namespace
      end

      #noinspection RubyResolve
      def puts_outcome(msg, result)
        outcome_str = result.present? ? "Success" : "Failure"
        color = result.present? ? :green : :red
        outcome_str = outcome_str.colorize(color)
        puts "#{msg}: #{outcome_str}".bold
      end
    end
  end
end