require 'active_record'

module AdaptiveAlias
  module Hooks
    module InsertAll
      def initialize(*, **)
        super

        adjust_keys_by_attribute_aliases
      end

      def execute
        AdaptiveAlias.rescue_statement_invalid(model_klass: @model) do
          adjust_keys_by_attribute_aliases
          super
        end
      end

      private

      def adjust_keys_by_attribute_aliases
        if @model.attribute_aliases.keys.any?{|s| @keys.include?(s) }
          @keys = @keys.map{|s| @model.attribute_aliases[s] || s }.to_set
          @inserts = @inserts.map{|insert| insert.transform_keys{|s| @model.attribute_aliases[s.to_s] || s } }
        end
      end
    end
  end
end

class ActiveRecord::InsertAll
  prepend AdaptiveAlias::Hooks::InsertAll
end
