# frozen_string_literal: true

require 'adaptive_alias/patches/base'

module AdaptiveAlias
  module Patches
    class ForwardPatch < Base
      def apply!
        AdaptiveAlias.current_patches[[@klass, @old_column, @new_column]] = self
        @klass.alias_attribute(@new_column, @old_column)
        add_hooks!(current_column: @old_column, alias_column: @new_column)
      end

      def do_remove!
        super
        @klass.remove_alias_attribute(@new_column)
        @klass.define_attribute_method(@new_column)
        new_patch = BackwardPatch.new(@klass, @old_column, @new_column)
        new_patch.apply!
        return new_patch
      end
    end
  end
end
