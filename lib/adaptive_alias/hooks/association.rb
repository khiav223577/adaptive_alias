module AdaptiveAlias
  module Hooks
    module Association
      def find_target(*)
        AdaptiveAlias.rescue_statement_invalid(nil, reflection){ super }
      end

      def create!(attributes = {}, &block)
        AdaptiveAlias.rescue_statement_invalid(association_scope, reflection){ super }
      end
    end
  end
end

class ActiveRecord::Associations::Association
  prepend AdaptiveAlias::Hooks::Association
end
