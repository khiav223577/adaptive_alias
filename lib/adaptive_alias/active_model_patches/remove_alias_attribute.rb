require 'active_model'

module ActiveModel::AttributeMethods
  module ClassMethods
    def alias_attribute(new_name, old_name)
      self.attribute_aliases = attribute_aliases.merge(new_name.to_s => old_name.to_s)
      attribute_method_matchers.each do |matcher|
        matcher_new = matcher.method_name(new_name).to_s
        matcher_old = matcher.method_name(old_name).to_s

        # define alias attribute method in the same module as other attributes do.
        # If we defined in self(model class), we will have to undef it in model class, too.
        # But undef methods in model class, those methods will never be accessible even if we define them in generated_attribute_methods module.
        define_proxy_call false, generated_attribute_methods, matcher_new, matcher_old
      end
    end

    def remove_proxy_call(mod, name)
      defn = if NAME_COMPILABLE_REGEXP.match?(name)
               "undef #{name}"
             else
               "remove_method(:'#{name}')"
             end

      mod.module_eval defn, __FILE__, __LINE__ + 1
    end

    def remove_alias_attribute(new_name)
      # association_scope -> add_constraints -> last_chain_scope -> where!(key => model[foreign_key])
      # self[attr_name] -> read_attribute(attr_name) -> attribute_aliases
      # where! -> where_clause_factory.build -> attributes = predicate_builder.resolve_column_aliases(opts) -> attribute_aliases
      self.attribute_aliases = attribute_aliases.except(new_name.to_s)

      attribute_method_matchers.each do |matcher|
        matcher_new = matcher.method_name(new_name).to_s
        remove_proxy_call generated_attribute_methods, matcher_new
      end
    end
  end
end
