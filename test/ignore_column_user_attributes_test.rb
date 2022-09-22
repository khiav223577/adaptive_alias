require 'test_helper'

class IgnoreColumnUserAttributesTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
  end

  def test_read
    user = Users::IgnoreColumnUser.find_by(name: 'Akka')
    profile_id = user.profile.id

    assert_queries(0) do
      assert_equal profile_id, user.profile_id_new
      assert_equal profile_id, user.profile_id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      user = Users::IgnoreColumnUser.find_by(name: 'Akka')
      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
        assert_equal profile_id, user.profile_id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = Users::IgnoreColumnUser.find_by(name: 'Akka')
      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
        assert_equal profile_id, user.profile_id
      end
    end
  end

  def test_write
    user = Users::IgnoreColumnUser.find_by(name: 'Akka')
    assert_queries(0) do
      user.profile_id = 123
      user.profile_id_new = 123
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      user = Users::IgnoreColumnUser.find_by(name: 'Akka')
      assert_queries(0) do
        user.profile_id = 123
        user.profile_id_new = 123
        assert_equal 123, user.profile_id
        assert_equal 123, user.profile_id_new
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = Users::IgnoreColumnUser.find_by(name: 'Akka')
      assert_queries(0) do
        user.profile_id = 123
        user.profile_id_new = 123
        assert_equal 123, user.profile_id
        assert_equal 123, user.profile_id_new
      end
    end
  end

  def test_read_write
    user = Users::IgnoreColumnUser.find_by(name: 'Akka')
    profile_id = user.profile.id

    assert_queries(0) do
      assert_equal profile_id, user.profile_id_new
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      user = Users::IgnoreColumnUser.find_by(name: 'Akka')

      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = Users::IgnoreColumnUser.find_by(name: 'Akka')

      assert_queries(0) do
        user.profile_id_new = 123
        assert_equal 123, user.profile_id_new
      end
    end
  end
end
