# frozen_string_literal: true
class User < ActiveRecord::Base
  include AdaptiveAlias[:profile_id, :profile_id_new]

  has_many :posts
  has_many :agent_posts, class_name: 'Posts::AgentPost'
  has_many :active_agent_posts, ->{ where(active: true) }, class_name: 'Posts::AgentPost'
  has_many :active_posts, ->{ where(active: true) }, class_name: 'Post'
  has_many :posts_reviews, through: :posts, source: :reviews, class_name: 'Review'
  has_many :active_posts_reviews, through: :active_posts, source: :reviews, class_name: 'Review'

  has_many :articles
  has_many :active_articles, ->{ where(active: true) }, class_name: 'Article'
  has_many :articles_reviews, through: :articles, source: :reviews, class_name: 'Review'
  has_many :active_articles_reviews, through: :active_articles, source: :reviews, class_name: 'Review'

  has_many :papers
  has_many :active_papers, ->{ where(active: true) }, class_name: 'Paper'
  has_many :papers_reviews, through: :papers, source: :reviews, class_name: 'Review'
  has_many :active_papers_reviews, through: :active_papers, source: :reviews, class_name: 'Review'

  belongs_to :profile

  acts_as_taggable
end
