# frozen_string_literal: true

module AdaptiveAlias
  module Patches
    class Base
      attr_reader :check_matched
      attr_reader :remove_and_fix_association
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
            self[new_column]
          end

          remove_method("#{new_column}=") if method_defined?("#{new_column}=")
          define_method("#{new_column}=") do |*args|
            super(*args)
          end

          remove_method(old_column) if method_defined?(old_column)
          define_method(old_column) do
            patch.log_warning if log_warning
            self[old_column]
          end

          remove_method("#{old_column}=") if method_defined?("#{old_column}=")
          define_method("#{old_column}=") do |*args|
            patch.log_warning if log_warning
            super(*args)
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

        @check_matched = proc do |relation, reflection, model, error|
          next false if not patch.removable

          # Error highlight behavior in Ruby 3.1 pollutes the error message
          error_msg = error.respond_to?(:original_message) ? error.original_message : error.message
          ambiguous = expected_ambiguous_association_err_msgs.include?(error_msg)

          if ambiguous
            next false if relation and klass.table_name != relation.klass.table_name
            next false if reflection and klass.table_name != reflection.klass.table_name
            next false if model and klass.table_name != model.class.table_name
            next false if !relation and !reflection and !model
          end

          next false if not expected_association_err_msgs.include?(error_msg) and not ambiguous
          next true
        end

        @remove_and_fix_association = proc do |relation, reflection, &block|
          patch.remove! do
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

            block.call
          end
        end
      end

      def log_warning
        if @prev_warning_time == nil || @prev_warning_time < Time.now - AdaptiveAlias.log_interval
          @prev_warning_time = Time.now
          AdaptiveAlias.unexpected_old_column_proc&.call
        end
      end

      def remove!
        if not @removed
          @removed = true
          new_patch = do_remove!
        end

        yield if block_given?
      ensure
        new_patch.mark_removable if new_patch
      end

      def do_remove!
        reset_caches(@klass)
        ActiveRecord::Base.descendants.each do |model_klass|
          reset_caches(model_klass) if model_klass.table_name == @klass.table_name
        end

        @check_matched = nil
        @remove_and_fix_association = nil
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
          when Arel::Nodes::Grouping
            each_nodes([node.expr], &block)
          when Arel::Nodes::Equality
            yield(node)
          when Arel::Nodes::And
            each_nodes(node.children, &block)
          when Arel::Nodes::Or
            each_nodes([node.left, node.right], &block)
          end
        end
      end
    end
  end
end
