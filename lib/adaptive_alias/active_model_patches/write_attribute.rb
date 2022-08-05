require 'active_record'

module AdaptiveAlias
  module ActiveModelPatches
    module WriteAttribute
      def write_attribute(attr_name, value)
        name = attr_name.to_s
        name = self.class.attribute_aliases[name] || name
        super(name, value)
      end

      # This method exists to avoid the expensive primary_key check internally, without
      # breaking compatibility with the write_attribute API
      def _write_attribute(attr_name, value) # :nodoc:
        name = attr_name.to_s
        name = self.class.attribute_aliases[name] || name
        super(name, value)
      end
    end
  end
end

module ActiveRecord::AttributeMethods::Write
  prepend AdaptiveAlias::ActiveModelPatches::WriteAttribute
end
