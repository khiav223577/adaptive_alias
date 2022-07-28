# frozen_string_literal: true

require 'adaptive_alias/patches/base'

module AdaptiveAlias
  module Patches
    class BackwardPatch < Base
      def apply!
        AdaptiveAlias.current_patches[[@klass, @old_column, @new_column]] = self
        @klass.alias_attribute(@old_column, @new_column)
        add_hooks!(current_column: @new_column, alias_column: @old_column, log_warning: true)
      end

      def remove!
        super
        @klass.remove_alias_attribute(@old_column)
        @klass.define_attribute_method(@old_column)
        ForwardPatch.new(@klass, @old_column, @new_column).apply!
      end
    end
  end
end
