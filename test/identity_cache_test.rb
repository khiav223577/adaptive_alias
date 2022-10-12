require 'test_helper'

class IdentityCacheTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
  end

  def test_old_cache_value
    user_id = User.find_by(name: 'Doggy').id

    assert_equal 'A1234', User.fetch_by_id(user_id).profile.id_number

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_equal 'A1234', User.fetch_by_id(user_id).profile.id_number

      # reload cache
      IdentityCache.cache.clear
      assert_equal 'A1234', User.fetch_by_id(user_id).profile.id_number

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_equal 'A1234', User.fetch_by_id(user_id).profile.id_number

      # reload cache
      IdentityCache.cache.clear
      assert_equal 'A1234', User.fetch_by_id(user_id).profile.id_number
    end
  end

  def test_new_cache_value
    user_id = User.find_by(name: 'Doggy').id

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_equal 'A1234', User.fetch_by_id(user_id).profile.id_number

      IdentityCache.cache.clear

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_equal 'A1234', User.fetch_by_id(user_id).profile.id_number

      IdentityCache.cache.clear
    end
  end

  def test_mixed
    user1_id = User.find_by(name: 'Doggy').id
    user2_name = User.find_by(name: 'Catty').name

    assert_equal 'A1234', User.fetch_by_id(user1_id).profile.id_number

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_equal 'B1234', User.fetch_by_name(user2_name).profile.id_number
      assert_equal 'A1234', User.fetch_by_id(user1_id).profile.id_number
      assert_equal 'B1234', User.fetch_by_name(user2_name).profile.id_number

      # reload cache
      IdentityCache.cache.clear
      assert_equal 'A1234', User.fetch_by_id(user1_id).profile.id_number

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_equal 'B1234', User.fetch_by_name(user2_name).profile.id_number
      assert_equal 'A1234', User.fetch_by_id(user1_id).profile.id_number
      assert_equal 'B1234', User.fetch_by_name(user2_name).profile.id_number

      # reload cache
      IdentityCache.cache.clear
      assert_equal 'A1234', User.fetch_by_id(user1_id).profile.id_number
    end
  end
end
