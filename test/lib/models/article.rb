# frozen_string_literal: true
class Article < ActiveRecord::Base
  include AdaptiveAlias[:user_id, :user_id_abc]

  belongs_to :user
end
