# frozen_string_literal: true

module AdaptiveAlias
  module Patches
    class Base
      attr_reader :removed

      def initialize(klass, old_column, new_column)
        @klass = klass
        @old_column = old_column
        @new_column = new_column
      end

      def add_hooks!(current_column:, log_warning: false)
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

        ActiveRecord::Associations::CollectionProxy.prepend(
          Module.new do
            define_method(:pluck) do |*column_names|
              begin
                super(*column_names)
              rescue ActiveRecord::StatementInvalid => e
                raise e if patch.removed || e.message != expected_error_message
                patch.remove!
                reload
              end
            end

            define_method(:load_target) do
              begin
                super()
              rescue ActiveRecord::StatementInvalid => e
                raise e if patch.removed || e.message != expected_error_message
                patch.remove!
                reload
              end
            end
          end
        )

        ActiveRecord::Associations::SingularAssociation.prepend(
          Module.new do
            define_method(:reader) do
              begin
                super()
              rescue ActiveModel::MissingAttributeError => e
                raise e if patch.removed
                patch.remove!
                retry
              end
            end
          end
        )
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
      end
    end
  end
end
