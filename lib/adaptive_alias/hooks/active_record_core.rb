module AdaptiveAlias
  module Hooks
    module ActiveRecordCore
      def find(*)
        AdaptiveAlias.rescue_statement_invalid{ super }
      end

      def find_by(*)
        AdaptiveAlias.rescue_statement_invalid{ super }
      end
    end
  end
end

# Nested module include is not supported until ruby 3.0
class << ActiveRecord::Base
  prepend AdaptiveAlias::Hooks::ActiveRecordCore
end
