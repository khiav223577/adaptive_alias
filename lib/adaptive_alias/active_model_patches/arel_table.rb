require 'active_record'

module AdaptiveAlias
  module ActiveModelPatches
    module ArelTable
      def [](name)
        name = name.to_s if name.is_a?(Symbol)
        klass = self.klass
        name = klass.attribute_aliases[name] || name if klass
        super
      end

      def klass
        return @type_caster.instance_variable_get(:@klass) if @type_caster.is_a?(ActiveRecord::TypeCaster::Connection)
        return @type_caster.send(:types) if @type_caster.is_a?(ActiveRecord::TypeCaster::Map)
      end
    end
  end
end

# https://github.com/rails/rails/commit/1ac40f16c5bc5246a4aaeab0558eb1c3078b3c6e
if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('6.1')
  class Arel::Table
    prepend AdaptiveAlias::ActiveModelPatches::ArelTable
  end
end
