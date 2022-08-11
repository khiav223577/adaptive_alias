# frozen_string_literal: true
class Paper < ActiveRecord::Base
  include AdaptiveAlias[:user_id, :new_user_id]

  belongs_to :user
  has_many :reviews, as: :reviewable
end
