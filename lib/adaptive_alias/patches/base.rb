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
          "Mysql2::Error: Unknown column '#{klass.table_name}.#{current_column}' in 'on clause'".freeze,
          "Mysql2::Error: Unknown column '#{klass.table_name}.#{current_column}' in 'field list'".freeze,
        ].freeze

        expected_ambiguous_association_err_msgs = [
          "Mysql2::Error: Unknown column '#{current_column}' in 'field list'".freeze,
        ].freeze

        expected_attribute_err_msgs = [
          "can't write unknown attribute `#{current_column}`".freeze,
          "missing attribute: #{current_column}".freeze,
        ].freeze

        @fix_missing_attribute = proc do |error_klass, error|
          next false if not patch.removable
          next false if patch.removed
          next false if klass.table_name != error_klass.table_name
          next false if not expected_attribute_err_msgs.include?(error.message)

          patch.remove!
          next true
        end

        fix_arel_attributes = proc do |attr|
          next if not attr.is_a?(Arel::Attributes::Attribute)
          next if attr.name != current_column.to_s
          next if klass.table_name != attr.relation.name

          attr.name = alias_column.to_s
        end

        fix_arel_nodes = proc do |nodes|
          each_nodes(nodes) do |node|
            fix_arel_attributes.call(node.left)
            fix_arel_attributes.call(node.right)
          end
        end

        @fix_association = proc do |relation, reflection, model, error|
          next false if not patch.removable
          next false if patch.removed

          ambiguous = expected_ambiguous_association_err_msgs.include?(error.message)

          if ambiguous
            next false if relation and klass.table_name != relation.klass.table_name
            next false if reflection and klass.table_name != reflection.klass.table_name
          end

          next false if not expected_association_err_msgs.include?(error.message) and not ambiguous

          patch.remove!

          if model
            attributes = model.instance_variable_get(:@attributes).instance_variable_get(:@attributes)
            attributes[alias_column.to_s] = attributes.delete(current_column.to_s)
          end

          if relation
            relation.reset # reset @arel

            joins = relation.arel.source.right # @ctx.source.right << create_join(relation, nil, klass)

            # adjust select fields
            index = relation.select_values.index(current_column)
            relation.select_values[index] = alias_column if index

            fix_arel_nodes.call(joins.map{|s| s.right.expr })
            fix_arel_nodes.call(relation.where_clause.send(:predicates))
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

        reset_caches(@klass)
        ActiveRecord::Base.descendants.each do |model_klass|
          reset_caches(model_klass) if model_klass.table_name == @klass.table_name
        end

        @fix_association = nil
        @fix_missing_attribute = nil
      end

      def mark_removable
        @removable = true
      end

      private

      def reset_caches(klass)
        # We need to call reload_schema_from_cache (which is called in reset_column_information),
        # in order to reset klass.attributes_builder which are initialized with outdated defaults.
        # If not, it will not raise missing attributes error when we try to access the column which has already been renamed,
        # and we will have no way to know the column has been renamed since no error is raised for us to rescue.
        klass.reset_column_information
        klass.columns_hash
      end

      def each_nodes(nodes, &block)
        nodes.each do |node|
          case node
          when Arel::Nodes::Equality
            yield(node)
          when Arel::Nodes::And
            each_nodes(node.children, &block)
          end
        end
      end
    end
  end
end
