require 'test_helper'

class UserAttributesTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
  end

  def test_read
    user = User.find_by(name: 'Catty')
    profile_id = user.profile.id

    assert_queries(0) do
      assert_equal profile_id, user.profile_id_new
      assert_equal profile_id, user.profile_id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      user = User.find_by(name: 'Catty')
      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
        assert_equal profile_id, user.profile_id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = User.find_by(name: 'Catty')
      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
        assert_equal profile_id, user.profile_id
      end
    end
  end

  def test_write
    user = User.find_by(name: 'Catty')
    assert_queries(0) do
      user.profile_id = 123
      user.profile_id_new = 123
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      user = User.find_by(name: 'Catty')
      assert_queries(0) do
        user.profile_id = 123
        user.profile_id_new = 123
        assert_equal 123, user.profile_id
        assert_equal 123, user.profile_id_new
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = User.find_by(name: 'Catty')
      assert_queries(0) do
        user.profile_id = 123
        user.profile_id_new = 123
        assert_equal 123, user.profile_id
        assert_equal 123, user.profile_id_new
      end
    end
  end

  def test_read_write
    user = User.find_by(name: 'Catty')
    profile_id = user.profile.id

    assert_queries(0) do
      assert_equal profile_id, user.profile_id_new
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      user = User.find_by(name: 'Catty')

      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = User.find_by(name: 'Catty')

      assert_queries(0) do
        user.profile_id_new = 123
        assert_equal 123, user.profile_id_new
      end
    end
  end

  def test_select_old_column
    assert_queries([
      'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
    ]) do
      assert_equal [1, 2], User.limit(2).select(:profile_id).map(&:profile_id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
        'SELECT `users`.`profile_id_new` FROM `users` LIMIT 2',
      ]) do
        assert_equal [1, 2], User.limit(2).select(:profile_id).map(&:profile_id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.`profile_id_new` FROM `users` LIMIT 2',
        'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
      ]) do
        assert_equal [1, 2], User.limit(2).select(:profile_id).map(&:profile_id)
      end
    end
  end

  def test_select_new_column
    assert_queries([
      'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
    ]) do
      assert_equal [1, 2], User.limit(2).select(:profile_id_new).map(&:profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
        'SELECT `users`.`profile_id_new` FROM `users` LIMIT 2',
      ]) do
        assert_equal [1, 2], User.limit(2).select(:profile_id_new).map(&:profile_id_new)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.`profile_id_new` FROM `users` LIMIT 2',
        'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
      ]) do
        assert_equal [1, 2], User.limit(2).select(:profile_id_new).map(&:profile_id_new)
      end
    end
  end

  def test_pluck_old_column
    assert_queries([
      'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
    ]) do
      assert_equal [1, 2], User.limit(2).pluck(:profile_id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
        'SELECT `users`.`profile_id_new` FROM `users` LIMIT 2',
      ]) do
        assert_equal [1, 2], User.limit(2).pluck(:profile_id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.`profile_id_new` FROM `users` LIMIT 2',
        'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
      ]) do
        assert_equal [1, 2], User.limit(2).pluck(:profile_id)
      end
    end
  end

  def test_pluck_new_column
    assert_queries([
      'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
    ]) do
      assert_equal [1, 2], User.limit(2).pluck(:profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
        'SELECT `users`.`profile_id_new` FROM `users` LIMIT 2',
      ]) do
        assert_equal [1, 2], User.limit(2).pluck(:profile_id_new)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.`profile_id_new` FROM `users` LIMIT 2',
        'SELECT `users`.`profile_id` FROM `users` LIMIT 2',
      ]) do
        assert_equal [1, 2], User.limit(2).pluck(:profile_id_new)
      end
    end
  end
end
