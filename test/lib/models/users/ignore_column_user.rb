# frozen_string_literal: true
module Users
  class IgnoreColumnUser < User
    self.ignored_columns = [:ignored_columns]
  end
end
