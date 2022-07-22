# frozen_string_literal: true

module AdaptiveAlias
  module Patches
    class Base
      attr_reader :fix_association
      attr_reader :fix_missing_attribute
      attr_reader :removed

      def initialize(klass, old_column, new_column)
        @klass = klass
        @old_column = old_column
        @new_column = new_column
      end

      def add_hooks!(current_column:, alias_column:, log_warning: false)
        patch = self
        old_column = @old_column
        new_column = @new_column

        @klass.prepend(
          Module.new do
            define_method(new_column) do
              begin
                self[new_column]
              rescue ActiveModel::MissingAttributeError => e
                raise e if patch.removed
                patch.remove!
                retry
              end
            end

            define_method(old_column) do
              patch.log_warning if log_warning

              begin
                self[old_column]
              rescue ActiveModel::MissingAttributeError => e
                raise e if patch.removed
                patch.remove!
                retry
              end
            end
          end
        )

        expected_error_message = "Mysql2::Error: Unknown column '#{@klass.table_name}.#{current_column}' in 'where clause'".freeze

        @fix_missing_attribute = proc do
          next false if patch.removed

          patch.remove!
        end

        @fix_association = proc do |target, error|
          next false if patch.removed || error.message != expected_error_message

          patch.remove!

          if target
            where_values_hash = target.where_values_hash
            where_values_hash[alias_column] = where_values_hash.delete(current_column) if where_values_hash.key?(current_column)
            target.instance_variable_set(:@arel, nil)
            target.unscope!(:where).where!(where_values_hash)
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
    end
  end
end
