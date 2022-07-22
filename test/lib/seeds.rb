ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.string :gender
  end
end

ActiveSupport::Dependencies.autoload_paths << File.expand_path('../models/', __FILE__)
if Gem::Version.new(ActiveRecord::VERSION::STRING) >= Gem::Version.new('7.0.0')
  require 'zeitwerk'
  loader = Zeitwerk::Loader.new
  ActiveSupport::Dependencies.autoload_paths.each{|s| loader.push_dir(s) }
  loader.setup # ready!
end

users = User.create([
  { name: 'Peter', email: 'peter@example.com', gender: 'male' },
  { name: 'Pearl', email: 'pearl@example.com', gender: 'female' },
  { name: 'Doggy', email: 'kathenrie@example.com', gender: 'female' },
  { name: 'Catty', email: 'catherine@example.com', gender: 'female' },
])
