module AdaptiveAlias
  module Hooks
    module AssociationScope
      def last_chain_scope(*)
        AdaptiveAlias.rescue_missing_attribute{ super }
      end
    end
  end
end

class ActiveRecord::Associations::AssociationScope
  prepend AdaptiveAlias::Hooks::AssociationScope
end

