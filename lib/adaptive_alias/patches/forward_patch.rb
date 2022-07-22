# frozen_string_literal: true

require 'adaptive_alias/patches/base'

module AdaptiveAlias
  module Patches
    class ForwardPatch < Base
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
  end
end
