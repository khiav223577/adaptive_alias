module AdaptiveAlias
  module Hooks
    module Association
      def find_target(*)
        AdaptiveAlias.rescue_statement_invalid(reflection: reflection){ super }
      end
    end
  end
end

class ActiveRecord::Associations::Association
  prepend AdaptiveAlias::Hooks::Association
end
