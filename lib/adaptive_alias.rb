# frozen_string_literal: true

require 'adaptive_alias/version'
require 'adaptive_alias/active_model_patches/read_attribute'
require 'adaptive_alias/active_model_patches/remove_alias_attribute'
require 'adaptive_alias/patches/back_patch'
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
          if column_names.include?(new_column)
            Patches::BackPatch.new(self, old_column, new_column).apply!
          else
            Patches::ForwardPatch.new(self, old_column, new_column).apply!
          end
        end
      end
    end

    def rescue_statement_invalid(relation)
      yield
    rescue ActiveRecord::StatementInvalid => error
      raise error if not AdaptiveAlias.current_patches.any? do |_key, patch|
                       patch.fix_association.call(relation, error)
                     end
      retry
    end

    def rescue_missing_attribute
      yield
    rescue ActiveModel::MissingAttributeError => error
      raise error if not AdaptiveAlias.current_patches.any?{|_key, patch| patch.fix_missing_attribute.call }
      retry
    end

    def get_or_create_model_module(klass)
      return @model_modules[klass] if @model_modules[klass]

      @model_modules[klass] = Module.new
      klass.prepend(@model_modules[klass])
      return @model_modules[klass]
    end
  end
end
