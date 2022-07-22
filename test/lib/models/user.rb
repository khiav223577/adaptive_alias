# frozen_string_literal: true
class User < ActiveRecord::Base
  has_many :posts
  has_many :active_posts, -> { where(active: true) }, class_name: 'Post'
end
