require 'active_model'

module AdaptiveAlias
  module ActiveModelPatches
    module RemoveAliasAttribute
      def remove_proxy_call(mod, name)
        mod.module_eval "remove_method(:'#{name}')", __FILE__, __LINE__ + 1
      end

      def remove_alias_attribute(new_name)
        self.attribute_aliases = attribute_aliases.except(new_name.to_s)

        attribute_method_matchers.each do |matcher|
          matcher_new = matcher.method_name(new_name).to_s
          remove_proxy_call self, matcher_new
        end
      end
    end
  end
end

# Nested module include is not supported until ruby 3.0
if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3')
  AdaptiveAlias::ActiveModelPatches::RemoveAliasAttribute.instance_methods.each do |method|
    ActiveModel::AttributeMethods::ClassMethods.define_method(method, AdaptiveAlias::ActiveModelPatches::RemoveAliasAttribute.instance_method(method))
  end
else
  module ActiveModel::AttributeMethods::ClassMethods
    include AdaptiveAlias::ActiveModelPatches::RemoveAliasAttribute
  end
end
