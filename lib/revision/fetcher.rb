module Kerbi
  module Revision
    module Fetcher
      # @return [Hash]
      def get_values
        {}
      end

      # @return [Array<Hash>]
      def self.post_template(base_url, revision_tag)
        [{}]
      end
    end
  end
end