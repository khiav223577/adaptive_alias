# frozen_string_literal: true
class Post < ActiveRecord::Base
  include AdaptiveAlias[:user_id_old, :user_id]

  belongs_to :user
  has_many :reviews, as: :reviewable
end
