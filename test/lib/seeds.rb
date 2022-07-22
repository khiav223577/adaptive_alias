ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
  end

  create_table :posts, :force => true do |t|
    t.integer :user_id_old
    t.string :title
    t.boolean :active
  end

  create_table :articles, :force => true do |t|
    t.integer :user_id
    t.string :title
    t.boolean :active
  end
end

require 'rails_compatibility/setup_autoload_paths'
RailsCompatibility.setup_autoload_paths [File.expand_path('../models/', __FILE__)]

users = User.create([
  { name: 'Doggy' },
  { name: 'Catty' },
])

Post.create([
  { title: 'Post A1', user_id_old: users[0].id, active: true },
  { title: 'Post B1', user_id_old: users[1].id, active: false },
  { title: 'Post B2', user_id_old: users[1].id, active: true },
  { title: 'Post B3', user_id_old: users[1].id, active: false },
])

Article.create([
  { title: 'Article A1', user_id: users[0].id, active: true },
  { title: 'Article B1', user_id: users[1].id, active: false },
  { title: 'Article B2', user_id: users[1].id, active: true },
  { title: 'Article B3', user_id: users[1].id, active: false },
])
