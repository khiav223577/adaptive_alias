module AdaptiveAlias
  module Hooks
    module Relation
      def pluck(*)
        AdaptiveAlias.rescue_statement_invalid(self){ super }
      end

      def select_all(*)
        AdaptiveAlias.rescue_statement_invalid(self){ super }
      end

      def exec_queries(*)
        AdaptiveAlias.rescue_statement_invalid(self){ super }
      end
    end
  end
end

class ActiveRecord::Relation
  prepend AdaptiveAlias::Hooks::Relation
end
