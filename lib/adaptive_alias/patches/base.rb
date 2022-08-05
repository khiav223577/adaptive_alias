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

        expected_association_err_msgs = [
          "Mysql2::Error: Unknown column '#{klass.table_name}.#{current_column}' in 'where clause'".freeze,
          "Mysql2::Error: Unknown column '#{current_column}' in 'field list'".freeze,
        ].freeze

        expected_attribute_err_msgs = [
          "can't write unknown attribute `#{current_column}`".freeze,
          "missing attribute: #{current_column}".freeze,
        ].freeze

        @fix_missing_attribute = proc do |error_klass, error|
          next false if not patch.removable
          next false if patch.removed
          next false if klass != error_klass
          next false if not expected_attribute_err_msgs.include?(error.message)

          patch.remove!
          next true
        end

        @fix_association = proc do |relation, reflection, error|
          next false if not patch.removable
          next false if patch.removed
          next false if not expected_association_err_msgs.include?(error.message)

          patch.remove!

          if relation
            relation.where_clause.send(:predicates).each do |node|
              next if node.left.name != current_column.to_s
              next if klass.table_name != node.left.relation.name

              node.left = node.left.clone
              node.left.name = alias_column.to_s
            end
          end

          reflection.clear_association_scope_cache if reflection

          next true
        end
      end

      def log_warning
        if @prev_warning_time == nil || @prev_warning_time < Time.now - AdaptiveAlias.log_interval
          @prev_warning_time = Time.now
          AdaptiveAlias.unexpected_old_column_proc&.call
        end
      end

      def remove!
        @removed = true
        @klass.reset_column_information
        @klass.columns_hash
        @fix_association = nil
        @fix_missing_attribute = nil
      end

      def mark_removable
        @removable = true
      end
    end
  end
end
