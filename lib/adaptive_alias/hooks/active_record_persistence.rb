module AdaptiveAlias
  module Hooks
    module ActiveRecordPersistence
      def _create_record(*)
        AdaptiveAlias.rescue_statement_invalid(model: self) do
          attribute_set_fix!
          super
        end
      end

      private

      def attribute_set_fix!
        if attribute_names.any?{|name| self.class.attribute_aliases[name] }
          attributes = @attributes.instance_variable_get(:@attributes)
          attributes.transform_keys! do |key|
            self.class.attribute_aliases[key] || key
          end
        end
      end
    end
  end
end

# Nested module include is not supported until ruby 3.0
class ActiveRecord::Base
  prepend AdaptiveAlias::Hooks::ActiveRecordPersistence
end
