# frozen_string_literal: true

module AdaptiveAlias
  module Patches
    class Base
      attr_reader :fix_association
      attr_reader :fix_missing_attribute
      attr_reader :removed
      attr_reader :removable

      def initialize(klass, old_column, new_column)
        @klass = klass
        @old_column = old_column
        @new_column = new_column
      end

      def add_hooks!(current_column:, alias_column:, log_warning: false)
        patch = self
        klass = @klass
        old_column = @old_column
        new_column = @new_column

        AdaptiveAlias.get_or_create_model_module(klass).instance_exec do
          remove_method(new_column) if method_defined?(new_column)
          define_method(new_column) do
            AdaptiveAlias.rescue_missing_attribute(klass){ self[new_column] }
          end

          remove_method("#{new_column}=") if method_defined?("#{new_column}=")
          define_method("#{new_column}=") do |*args|
            AdaptiveAlias.rescue_missing_attribute(klass){ super(*args) }
          end

          remove_method(old_column) if method_defined?(old_column)
          define_method(old_column) do
            patch.log_warning if log_warning
            AdaptiveAlias.rescue_missing_attribute(klass){ self[old_column] }
          end

          remove_method("#{old_column}=") if method_defined?("#{old_column}=")
          define_method("#{old_column}=") do |*args|
            patch.log_warning if log_warning
            AdaptiveAlias.rescue_missing_attribute(klass){ super(*args) }
          end
        end

        expected_error_message = "Mysql2::Error: Unknown column '#{klass.table_name}.#{current_column}' in 'where clause'".freeze

        @fix_missing_attribute = proc do |error_klass|
          next false if not patch.removable
          next false if patch.removed
          next false if klass != error_klass

          patch.remove!
          next true
        end

        @fix_association = proc do |target, error|
          next false if not patch.removable
          next false if patch.removed
          next false if error.message != expected_error_message

          patch.remove!

          if target
            hash = target.where_values_hash
            hash[alias_column] = hash.delete(current_column) if hash.key?(current_column)
            target.instance_variable_set(:@arel, nil)
            target.unscope!(:where).where!(hash)
          end

          next true
        end
      end

      def log_warning
        if @prev_warning_time == nil || @prev_warning_time < AdaptiveAlias.log_interval.ago
          @prev_warning_time = Time.now
          AdaptiveAlias.unexpected_old_column_proc&.call
        end
      end

      def remove!
        @removed = true
        @klass.send(:reload_schema_from_cache)
        @klass.initialize_find_by_cache
        @fix_association = nil
        @fix_missing_attribute = nil
      end

      def mark_removable
        @removable = true
      end
    end
  end
end
