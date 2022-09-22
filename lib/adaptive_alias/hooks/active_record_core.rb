module AdaptiveAlias
  module Hooks
    module ActiveRecordCore
      def find(*)
        AdaptiveAlias.rescue_statement_invalid(nil, nil){ super }
      end

      def find_by(*)
        AdaptiveAlias.rescue_statement_invalid(nil, nil){ super }
      end
    end
  end
end

module ActiveRecord::Core::ClassMethods
  prepend AdaptiveAlias::Hooks::ActiveRecordCore
end
