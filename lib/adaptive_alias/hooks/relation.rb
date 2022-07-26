module AdaptiveAlias
  module Hooks
    module Relation
      def pluck(*)
        AdaptiveAlias.rescue_statement_invalid(relation: self){ super }
      end

      def update_all(*)
        AdaptiveAlias.rescue_statement_invalid(relation: self){ super }
      end

      def exists?(*)
        AdaptiveAlias.rescue_statement_invalid(relation: self){ super }
      end

      def select_all(*)
        AdaptiveAlias.rescue_statement_invalid(relation: self){ super }
      end

      def exec_queries(*)
        AdaptiveAlias.rescue_statement_invalid(relation: self){ super }
      end
    end
  end
end

class ActiveRecord::Relation
  prepend AdaptiveAlias::Hooks::Relation
end
