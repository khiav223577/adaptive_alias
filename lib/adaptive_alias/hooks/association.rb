module AdaptiveAlias
  module Hooks
    module Association
      def find_target(*)
        AdaptiveAlias.rescue_statement_invalid(reflection: reflection){ super }
      end

      def create!(attributes = {}, &block)
        AdaptiveAlias.rescue_statement_invalid(relation: association_scope, reflection: reflection){ super }
      end
    end
  end
end

class ActiveRecord::Associations::Association
  prepend AdaptiveAlias::Hooks::Association
end
