module AdaptiveAlias
  module Hooks
    module AssociationScope
      def last_chain_scope(_scope, reflection, owner)
        AdaptiveAlias.rescue_missing_attribute(owner.class){ super }
      end
    end
  end
end

class ActiveRecord::Associations::AssociationScope
  prepend AdaptiveAlias::Hooks::AssociationScope
end
