# frozen_string_literal: true
class User < ActiveRecord::Base
  has_many :posts
  has_many :active_posts, -> { where(active: true) }, class_name: 'Post'

  has_many :articles
  has_many :active_articles, -> { where(active: true) }, class_name: 'Article'
end
