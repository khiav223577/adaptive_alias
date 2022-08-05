# frozen_string_literal: true
class User < ActiveRecord::Base
  include AdaptiveAlias[:profile_id, :profile_id_new]

  has_many :posts
  has_many :active_posts, ->{ where(active: true) }, class_name: 'Post'
  has_many :posts_reviews, through: :posts, source: :reviews

  has_many :articles
  has_many :active_articles, ->{ where(active: true) }, class_name: 'Article'
  has_many :articles_reviews, through: :articles, source: :reviews

  belongs_to :profile

  acts_as_taggable
end
