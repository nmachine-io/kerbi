module Kerbi
  module Cli
    class BaseSerializer

      attr_reader :object
      attr_reader :parent_object
      attr_reader :context

      def initialize(object, context={})
        @object = object
        @parent_object = context.delete(:parent_object)
        @context = context
      end

      def serialize
        flat_attrs = serialize_flat_attrs
        assoc_attrs = serialize_associations
        poss_attrs = serialize_possessions
        flat_attrs.merge(assoc_attrs).merge(poss_attrs)
      end

      def serialize_flat_attrs
        Hash[self.class.attributes.map do |attribute_name|
          [attribute_name, attribute_value(attribute_name)]
        end]
      end

      def serialize_possessions
        Hash[self.class.possessions.map do |possession|
          attr = possession[:attr] || possession[:name]
          value = attribute_value(attr)
          serialized_value = value && begin
                                        serialized_relation_value(possession, value)
                                      end
          [attr, serialized_value]
        end]
      end

      def serialize_associations
        Hash[self.class.associations.map do |association|
          attr = association[:attr] || association[:name]
          values = attribute_value(attr)
          values = limit_has_many(attr, values)
          serialized_array = values.map do |value|
            serialized_relation_value(association, value)
          end
          [attr, serialized_array]
        end]
      end

      def serialized_relation_value(relation, value)
        serializer = relation[:serializer]
        new_context = context.merge(parent_object: object)
        serializer.serialize(value, new_context)
      end

      def attribute_value(name)
        receiver = self.respond_to?(name) ? self : object
        receiver.send(name)
      end

      def limit_has_many(association_name, query_result)
        limit_quantity = context["#{association_name}_limit".to_sym]
        limit_quantity && query_result.limit(limit_quantity) || query_result
      end

      def key
        object.id
      end

      def self.has_many(name, serializer, attr=nil)
        @associations ||= []
        @associations << {
          name: name.to_sym,
          serializer: serializer,
          attr: attr
        }
      end

      def self.has_one(name, serializer, attr=nil)
        @possessions ||= []
        @possessions << {
          name: name.to_sym,
          serializer: serializer,
          attr: attr
        }
      end

      def self.possessions
        @possessions ||= []
      end

      def self.associations
        @associations ||= []
      end

      def self.attributes
        @attributes ||= []
      end

      def self.has_attributes(*attrs)
        @attributes = attrs.map(&:to_sym)
      end

      def self.header_titles
        attributes.map(&:to_s).map(&:upcase)
      end

      def self.serialize(object, context={})
        instance = new(object, context)
        instance.serialize
      end

      def self.serialize_many(objects, context={})
        out = objects.map {|object| serialize(object, context)}
        { data: out }
      end
    end
  end
end