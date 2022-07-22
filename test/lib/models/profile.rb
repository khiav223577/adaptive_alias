# frozen_string_literal: true
class Profile < ActiveRecord::Base
  has_one :user
end
