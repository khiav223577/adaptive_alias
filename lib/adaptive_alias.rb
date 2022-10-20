# frozen_string_literal: true

require 'adaptive_alias/version'
require 'adaptive_alias/active_model_patches/read_attribute'
require 'adaptive_alias/active_model_patches/write_attribute'
require 'adaptive_alias/active_model_patches/remove_alias_attribute'
require 'adaptive_alias/active_model_patches/apply_scope'
require 'adaptive_alias/active_model_patches/arel_table'
require 'adaptive_alias/patches/backward_patch'
require 'adaptive_alias/patches/forward_patch'

require 'adaptive_alias/hooks/association'
require 'adaptive_alias/hooks/relation'
require 'adaptive_alias/hooks/active_record_core'
require 'adaptive_alias/hooks/active_record_persistence'
require 'adaptive_alias/hooks/calculations'
require 'adaptive_alias/hooks/insert_all'

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
          patch = (column_names.include?(new_column.to_s) ? Patches::BackwardPatch : Patches::ForwardPatch).new(self, old_column, new_column)
          patch.apply!
          patch.mark_removable
        end
      end
    end

    def rescue_statement_invalid(relation: nil, reflection: nil, model_klass: nil, &block)
      yield
    rescue ActiveRecord::StatementInvalid => error
      _key, patch = AdaptiveAlias.current_patches.find{|_key, patch| patch.check_matched.call(relation, reflection, model_klass, error) }
      raise error if patch == nil

      patch.remove_and_fix_association.call(relation, reflection) do
        return rescue_statement_invalid(relation: relation, reflection: reflection, model_klass: model_klass, &block)
      end
    end

    def get_or_create_model_module(klass)
      return @model_modules[klass] if @model_modules[klass]

      @model_modules[klass] = Module.new
      klass.prepend(@model_modules[klass])
      return @model_modules[klass]
    end
  end
end
