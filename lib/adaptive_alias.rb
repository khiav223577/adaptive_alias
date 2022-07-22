# frozen_string_literal: true

require 'adaptive_alias/version'
require 'adaptive_alias/patches/read_attribute'
require 'adaptive_alias/patches/remove_alias_attribute'

module AdaptiveAlias
  @log_interval = 10 * 60

  class << self
    attr_accessor :unexpected_old_column_proc
    attr_accessor :log_interval
    attr_accessor :current_patch
  end

  class Patch
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

      @klass.define_method(new_column) do
        begin
          self[new_column]
        rescue ActiveModel::MissingAttributeError => e
          raise e if patch.removed
          patch.remove!
          retry
        end
      end

      @klass.define_method(old_column) do
        patch.log_warning if log_warning

        begin
          self[old_column]
        rescue ActiveModel::MissingAttributeError => e
          raise e if patch.removed
          patch.remove!
          retry
        end
      end

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
    end
  end

  class BackPatch < Patch
    def apply!
      AdaptiveAlias.current_patch = self
      @klass.alias_attribute(@old_column, @new_column)
      add_hooks!(current_column: @new_column, log_warning: true)
    end

    def remove!
      super
      @klass.remove_alias_attribute(@old_column)
      ForwardPatch.new(@klass, @old_column, @new_column).apply!
    end
  end

  class ForwardPatch < Patch
    def apply!
      AdaptiveAlias.current_patch = self
      @klass.alias_attribute(@new_column, @old_column)
      add_hooks!(current_column: @old_column)
    end

    def remove!
      super
      @klass.remove_alias_attribute(@new_column)
      BackPatch.new(@klass, @old_column, @new_column).apply!
    end
  end

  class << self
    def [](old_column, new_column)
      old_column = old_column.to_sym
      new_column = new_column.to_sym

      Module.new do
        extend ActiveSupport::Concern

        included do
          if column_names.include?(new_column)
            BackPatch.new(self, old_column, new_column).apply!
          else
            ForwardPatch.new(self, old_column, new_column).apply!
          end
        end
      end
    end
  end
end
