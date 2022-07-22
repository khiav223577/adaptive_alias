module AdaptiveAlias
  module Hooks
    module SingularAssociation
      def reader(*)
        AdaptiveAlias.rescue_missing_attribute{ super }
      end
    end
  end
end

class ActiveRecord::Associations::SingularAssociation
  prepend AdaptiveAlias::Hooks::SingularAssociation
end
