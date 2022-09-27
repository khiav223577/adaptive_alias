module AdaptiveAlias
  module Hooks
    module ActiveRecordPersistence
      def _create_record(*)
        AdaptiveAlias.rescue_statement_invalid(model: self){ super }
      end
    end
  end
end

# Nested module include is not supported until ruby 3.0
class ActiveRecord::Base
  prepend AdaptiveAlias::Hooks::ActiveRecordPersistence
end
