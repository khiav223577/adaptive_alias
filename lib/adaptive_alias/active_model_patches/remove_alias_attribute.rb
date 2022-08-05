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

module ActiveModel::AttributeMethods::ClassMethods
  include AdaptiveAlias::ActiveModelPatches::RemoveAliasAttribute
end
