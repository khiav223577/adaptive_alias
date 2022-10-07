ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :type
    t.string :name
    t.string :ignored_columns
    t.integer :profile_id
  end

  create_table :posts, force: true do |t|
    t.string :type
    t.integer :user_id_old, null: false
    t.string :title
    t.boolean :active
  end

  create_table :articles, force: true do |t|
    t.integer :user_id, null: false
    t.string :title
    t.boolean :active
  end

  create_table :papers, force: true do |t|
    t.integer :new_user_id, null: false
    t.string :title
    t.boolean :active
  end

  create_table :profiles, force: true do |t|
    t.string :id_number
  end

  create_table :tags, force: true do |t|
    t.string :name
    t.integer :taggings_count
  end

  create_table :taggings, force: true do |t|
    t.integer :tag_id, null: false
    t.string :taggable_type, null: false
    t.integer :taggable_id, null: false
    t.string :tagger_type
    t.integer :tagger_id
    t.string :context
  end

  create_table :reviews, force: true do |t|
    t.text :content
    t.belongs_to :reviewable, polymorphic: true, null: false
  end
end

require 'rails_compatibility/setup_autoload_paths'
RailsCompatibility.setup_autoload_paths [File.expand_path('../models/', __FILE__)]

users = User.create!([
  { name: 'Doggy', profile: Profile.new(id_number: 'A1234') },
  { name: 'Catty', profile: Profile.new(id_number: 'B1234') },
  { type: 'Users::AgentUser', name: 'Pepper', profile: Profile.new(id_number: 'C1234') },
  { type: 'Users::AgentUser', name: 'Hachu', profile: Profile.new(id_number: 'D1234') },
  { type: 'Users::IgnoreColumnUser', name: 'Akka', profile: Profile.new(id_number: 'E1234') },
  { type: 'Users::IgnoreColumnUser', name: 'Amiya' },
])

users[0].tag_list.add('awesome', 'slick')
users[0].save!

posts = Post.create!([
  { title: 'Post A1', user_id_old: users[0].id, active: true },
  { title: 'Post B1', user_id_old: users[1].id, active: false },
  { title: 'Post B2', user_id_old: users[1].id, active: true },
  { title: 'Post B3', user_id_old: users[1].id, active: false },
  { title: 'Post C1', user_id_old: users[2].id, active: false },
  { title: 'Post C2', user_id_old: users[2].id, active: true },
  { title: 'Post C3', user_id_old: users[2].id, active: false },
  { type: 'Posts::AgentPost', title: 'Post D1', user_id_old: users[3].id, active: false },
  { type: 'Posts::AgentPost', title: 'Post D2', user_id_old: users[3].id, active: true },
  { type: 'Posts::AgentPost', title: 'Post D3', user_id_old: users[3].id, active: false },
])

posts[0].reviews.create!(content: 'post review A1')
posts[1].reviews.create!(content: 'post review B1')
posts[1].reviews.create!(content: 'post review B2')
posts[2].reviews.create!(content: 'post review C1')

articles = Article.create!([
  { title: 'Article A1', user_id: users[0].id, active: true },
  { title: 'Article B1', user_id: users[1].id, active: false },
  { title: 'Article B2', user_id: users[1].id, active: true },
  { title: 'Article B3', user_id: users[1].id, active: false },
])

articles[0].reviews.create!(content: 'article review A1')
articles[1].reviews.create!(content: 'article review B1')
articles[1].reviews.create!(content: 'article review B2')
articles[2].reviews.create!(content: 'article review C1')

papers = Paper.create!([
  { title: 'Paper A1', new_user_id: users[0].id, active: true },
  { title: 'Paper B1', new_user_id: users[1].id, active: false },
  { title: 'Paper B2', new_user_id: users[1].id, active: true },
  { title: 'Paper B3', new_user_id: users[1].id, active: false },
])

papers[0].reviews.create!(content: 'paper review A1')
papers[1].reviews.create!(content: 'paper review B1')
papers[1].reviews.create!(content: 'paper review B2')
papers[2].reviews.create!(content: 'paper review C1')
