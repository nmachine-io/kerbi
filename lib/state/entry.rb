module Kerbi
  module State
    class Entry
      attr_reader :id
      attr_reader :message
      attr_reader :values
      attr_reader :created_at

      def candidate?
        id == 'candidate'
      end

      def to_dict
        {
          id: id,
          message: message,
          values: values,
          created_at: created_at.to_s
        }
      end
    end
  end
end