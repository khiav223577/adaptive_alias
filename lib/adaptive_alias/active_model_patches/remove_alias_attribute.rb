require 'active_model'

module ActiveModel::AttributeMethods
  module ClassMethods
    if Gem::Version.new(ActiveRecord::VERSION::STRING) >= Gem::Version.new('7.0')
      def alias_attribute(new_name, old_name)
        self.attribute_aliases = attribute_aliases.merge(new_name.to_s => old_name.to_s)
        ActiveSupport::CodeGenerator.batch(generated_attribute_methods, __FILE__, __LINE__) do |code_generator|
          attribute_method_matchers.each do |matcher|
            method_name = matcher.method_name(new_name).to_s
            target_name = matcher.method_name(old_name).to_s
            parameters = matcher.parameters

            mangled_name = target_name
            unless NAME_COMPILABLE_REGEXP.match?(target_name)
              mangled_name = "__temp__#{target_name.unpack1("h*")}"
            end

            code_generator.define_cached_method(method_name, as: mangled_name, namespace: :alias_attribute) do |batch|
              body = if CALL_COMPILABLE_REGEXP.match?(target_name)
                       "self.#{target_name}(#{parameters || ''})"
                     else
                       call_args = [":'#{target_name}'"]
                       call_args << parameters if parameters
                       "send(#{call_args.join(", ")})"
                     end

              modifier = matcher.parameters == FORWARD_PARAMETERS ? "ruby2_keywords " : ""

              batch <<
                "#{modifier}def #{mangled_name}(#{parameters || ''})" <<
                body <<
                "end"
            end
          end
        end
      end
    elsif Gem::Version.new(ActiveRecord::VERSION::STRING) >= Gem::Version.new('6.1')
      def alias_attribute(new_name, old_name)
        self.attribute_aliases = attribute_aliases.merge(new_name.to_s => old_name.to_s)
        CodeGenerator.batch(generated_attribute_methods, __FILE__, __LINE__) do |owner|
          attribute_method_matchers.each do |matcher|
            matcher_new = matcher.method_name(new_name).to_s
            matcher_old = matcher.method_name(old_name).to_s
            define_proxy_call false, owner, matcher_new, matcher_old
          end
        end
      end
    else
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
    end

    def remove_alias_attribute(new_name)
      self.attribute_aliases = attribute_aliases.except(new_name.to_s)

      attribute_method_matchers.each do |matcher|
        matcher_new = matcher.method_name(new_name).to_s
        remove_proxy_call generated_attribute_methods, matcher_new
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
  end
end
