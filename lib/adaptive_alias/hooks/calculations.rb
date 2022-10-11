require 'active_record'

module AdaptiveAlias
  module Hooks
    module Calculations
      def perform_calculation(*)
        AdaptiveAlias.rescue_statement_invalid(relation: self){ super }
      end
    end
  end
end

# Nested module include is not supported until ruby 3.0
class ActiveRecord::Relation
  prepend AdaptiveAlias::Hooks::Calculations
end
