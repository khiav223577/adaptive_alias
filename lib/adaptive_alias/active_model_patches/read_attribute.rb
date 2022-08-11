require 'active_record'

module AdaptiveAlias
  module ActiveModelPatches
    module ReadAttribute
      def read_attribute(attr_name, &block) # :nodoc:
        name = attr_name.to_s
        name = self.class.attribute_aliases[name] || name

        name = @primary_key if name == 'id' && @primary_key
        _read_attribute(name, &block)
      end

      # This method exists to avoid the expensive primary_key check internally, without
      # breaking compatibility with the write_attribute API
      def _read_attribute(attr_name, &block) # :nodoc:
        name = attr_name.to_s
        name = self.class.attribute_aliases[name] || name

        sync_with_transaction_state if @transaction_state&.finalized?
        return yield(name) if block_given? and AdaptiveAlias.missing_value?(@attributes, self.class, name)
        return @attributes.fetch_value(name, &block)
      end
    end
  end
end

# Nested module include is not supported until ruby 3.0
class ActiveRecord::Base
  prepend AdaptiveAlias::ActiveModelPatches::ReadAttribute
end
