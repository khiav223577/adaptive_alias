module AdaptiveAlias
  module Hooks
    module ActiveRecordPersistence
      def _update_record
        AdaptiveAlias.rescue_statement_invalid(model_klass: self.class) do
          attribute_set_fix!
          super
        end
      end

      def _create_record(*)
        AdaptiveAlias.rescue_statement_invalid(model_klass: self.class) do
          attribute_set_fix!
          super
        end
      end

      private

      def attribute_set_fix!
        if attribute_names.any?{|name| self.class.attribute_aliases[name] }
          attributes = @attributes.instance_variable_get(:@attributes)
          attributes = attributes.instance_variable_get(:@delegate_hash) if attributes.is_a?(ActiveModel::LazyAttributeHash)

          delete_duplicate_keys!(attributes)

          attributes.transform_keys! do |key|
            self.class.attribute_aliases[key] || key
          end
        end
      end

      # delete duplicate keys caused by instantiate after migration but before patch removal.
      def delete_duplicate_keys!(attributes)
        duplicate_keys = {}
        delete_keys = []
        attributes.each do |key, _|
          aliased_key = self.class.attribute_aliases[key] || key
          delete_keys << key if duplicate_keys[aliased_key] # delete old key and keep the new one
          duplicate_keys[aliased_key] = true
        end

        delete_keys.each{|s| attributes.delete(s) }
      end
    end
  end
end

# Nested module include is not supported until ruby 3.0
class ActiveRecord::Base
  prepend AdaptiveAlias::Hooks::ActiveRecordPersistence
end
