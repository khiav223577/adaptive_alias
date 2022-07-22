# frozen_string_literal: true

require 'adaptive_alias/version'
require 'adaptive_alias/active_model_patches/read_attribute'
require 'adaptive_alias/active_model_patches/remove_alias_attribute'
require 'adaptive_alias/patches/back_patch'
require 'adaptive_alias/patches/forward_patch'

module AdaptiveAlias
  @log_interval = 10 * 60

  class << self
    attr_accessor :unexpected_old_column_proc
    attr_accessor :log_interval
    attr_accessor :current_patch
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
  end
end
