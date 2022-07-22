# frozen_string_literal: true

require 'adaptive_alias/version'
require 'adaptive_alias/active_model_patches/read_attribute'
require 'adaptive_alias/active_model_patches/remove_alias_attribute'
require 'adaptive_alias/patches/back_patch'
require 'adaptive_alias/patches/forward_patch'

require 'adaptive_alias/hooks/association'
require 'adaptive_alias/hooks/relation'

module AdaptiveAlias
  @log_interval = 10 * 60
  @current_patches = {}

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

    def run_with_statement_invalid_rescue(relation)
      begin
        yield
      rescue ActiveRecord::StatementInvalid => error
        AdaptiveAlias.fix_association(relation, error)
        retry
      end
    end

    def fix_association(relation, error)
      return if AdaptiveAlias.current_patches.any?{|_key, patch| patch.fix_association.call(relation, error) }

      raise error
    end
  end
end
