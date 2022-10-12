require 'test_helper'

class IdentityCacheTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
  end

  def test_cache_after_migrate
    user1 = User.find_by(name: 'Doggy')
    user2 = User.find_by(name: 'Catty')

    assert_equal 'A1234', User.fetch_by_id(user1.id).profile.id_number

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_equal 'B1234', User.fetch_by_name(user2.name).profile.id_number
      assert_equal 'A1234', User.fetch_by_id(user1.id).profile.id_number
      assert_equal 'B1234', User.fetch_by_name(user2.name).profile.id_number

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_equal 'B1234', User.fetch_by_name(user2.name).profile.id_number
      assert_equal 'A1234', User.fetch_by_id(user1.id).profile.id_number
      assert_equal 'B1234', User.fetch_by_name(user2.name).profile.id_number
    end
  end
end
