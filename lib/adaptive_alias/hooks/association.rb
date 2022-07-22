module AdaptiveAlias
  module Hooks
    module Association
      def find_target
        AdaptiveAlias.run_with_statement_invalid_rescue(nil){ super }
      end
    end
  end
end

class ActiveRecord::Associations::Association
  prepend AdaptiveAlias::Hooks::Association
end
