# frozen_string_literal: true

require 'adaptive_alias/version'
require 'adaptive_alias/active_model_patches/read_attribute'
require 'adaptive_alias/active_model_patches/remove_alias_attribute'
require 'adaptive_alias/patches/backward_patch'
require 'adaptive_alias/patches/forward_patch'

require 'adaptive_alias/hooks/association'
require 'adaptive_alias/hooks/association_scope'
require 'adaptive_alias/hooks/singular_association'
require 'adaptive_alias/hooks/relation'

module AdaptiveAlias
  @log_interval = 10 * 60
  @current_patches = {}
  @model_modules ||= {}

  class << self
    attr_accessor :unexpected_old_column_proc
    attr_accessor :log_interval
    attr_accessor :current_patches
  end

  class << self
    def [](old_column, new_column)
      old_column = old_column.to_sym
      new_column = new_column.to_sym

      Module.new do
        extend ActiveSupport::Concern

        included do
          patch = (column_names.include?(new_column) ? Patches::BackwardPatch : Patches::ForwardPatch).new(self, old_column, new_column)
          patch.apply!
          patch.mark_removable
        end
      end
    end

    def rescue_statement_invalid(relation, &block)
      yield
    rescue ActiveRecord::StatementInvalid => error
      raise error if AdaptiveAlias.current_patches.all?{|_key, patch| !patch.fix_association.call(relation, error) }

      result = rescue_statement_invalid(relation, &block)
      AdaptiveAlias.current_patches.each_value(&:mark_removable)
      return result
    end

    def rescue_missing_attribute(klass, &block)
      yield
    rescue ActiveModel::MissingAttributeError => error
      raise error if AdaptiveAlias.current_patches.all?{|_key, patch| !patch.fix_missing_attribute.call(klass) }

      result = rescue_missing_attribute(klass, &block)
      AdaptiveAlias.current_patches.each_value(&:mark_removable)
      return result
    end

    def get_or_create_model_module(klass)
      return @model_modules[klass] if @model_modules[klass]

      @model_modules[klass] = Module.new
      klass.prepend(@model_modules[klass])
      return @model_modules[klass]
    end

    def missing_value?(attributes, klass, name)
      return false if attributes.key?(name)

      old_name = klass.attribute_aliases.key(name)
      return false if old_name == nil
      return !!AdaptiveAlias.current_patches[[klass, old_name.to_sym, name.to_sym]]
    end
  end
end
