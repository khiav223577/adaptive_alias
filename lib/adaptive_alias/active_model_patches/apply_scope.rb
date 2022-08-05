require 'active_record'

module AdaptiveAlias
  module ActiveModelPatches
    module ApplyScope
      def apply_scope(scope, table, key, value)
        klass = table.instance_variable_get(:@klass) || table.send(:type_caster).send(:types)
        key = klass.attribute_aliases[key] || key
        super(scope, table, key, value)
      end
    end
  end
end

class ActiveRecord::Associations::AssociationScope
  prepend AdaptiveAlias::ActiveModelPatches::ApplyScope
end
