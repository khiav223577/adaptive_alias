module AdaptiveAlias
  module Hooks
    module Relation
      def pluck(*)
        AdaptiveAlias.run_with_statement_invalid_rescue(self){ super }
      end

      def select_all(*)
        AdaptiveAlias.run_with_statement_invalid_rescue(self){ super }
      end

      def exec_queries(*)
        AdaptiveAlias.run_with_statement_invalid_rescue(self){ super }
      end
    end
  end
end

class ActiveRecord::Relation
  prepend AdaptiveAlias::Hooks::Relation
end
