require 'test_helper'

class UserModelQueryingTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
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
      'SELECT `users`.`profile_id` FROM `users`',
    ]) do
      assert_equal [1, 2], User.pluck(:profile_id).first(2)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.`profile_id` FROM `users`',
        'SELECT `users`.`profile_id_new` FROM `users`',
      ]) do
        assert_equal [1, 2], User.pluck(:profile_id).first(2)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.`profile_id_new` FROM `users`',
        'SELECT `users`.`profile_id` FROM `users`',
      ]) do
        assert_equal [1, 2], User.pluck(:profile_id).first(2)
      end
    end
  end

  def test_pluck_new_column
    assert_queries([
      'SELECT `users`.`profile_id` FROM `users`',
    ]) do
      assert_equal [1, 2], User.pluck(:profile_id_new).first(2)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.`profile_id` FROM `users`',
        'SELECT `users`.`profile_id_new` FROM `users`',
      ]) do
        assert_equal [1, 2], User.pluck(:profile_id_new).first(2)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.`profile_id_new` FROM `users`',
        'SELECT `users`.`profile_id` FROM `users`',
      ]) do
        assert_equal [1, 2], User.pluck(:profile_id_new).first(2)
      end
    end
  end

  def test_relation_pluck_old_column
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

  def test_relation_pluck_new_column
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

  def test_find_by_old_column
    assert_queries([
      'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
    ]) do
      assert_equal 1, User.find_by(profile_id: 1).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.find_by(profile_id: 1).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.find_by(profile_id: 1).id
      end
    end
  end

  def test_find_by_new_column
    assert_queries([
      'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
    ]) do
      assert_equal 1, User.find_by(profile_id_new: 1).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.find_by(profile_id_new: 1).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.find_by(profile_id_new: 1).id
      end
    end
  end

  def test_relation_find_by_old_column
    assert_queries([
      'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
    ]) do
      assert_equal 1, User.limit(1).find_by(profile_id: 1).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.limit(1).find_by(profile_id: 1).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.limit(1).find_by(profile_id: 1).id
      end
    end
  end

  def test_relation_find_by_new_column
    assert_queries([
      'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
    ]) do
      assert_equal 1, User.limit(1).find_by(profile_id_new: 1).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.limit(1).find_by(profile_id_new: 1).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.limit(1).find_by(profile_id_new: 1).id
      end
    end
  end

  def test_relation_find_old_column
    assert_queries([
      'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 AND `users`.`id` = 1 LIMIT 1',
    ]) do
      assert_equal 1, User.where(profile_id: 1).find(1).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 AND `users`.`id` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 AND `users`.`id` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.where(profile_id: 1).find(1).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 AND `users`.`id` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 AND `users`.`id` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.where(profile_id: 1).find(1).id
      end
    end
  end

  def test_relation_find_new_column
    assert_queries([
      'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 AND `users`.`id` = 1 LIMIT 1',
    ]) do
      assert_equal 1, User.where(profile_id_new: 1).find(1).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 AND `users`.`id` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 AND `users`.`id` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).find(1).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id_new` = 1 AND `users`.`id` = 1 LIMIT 1',
        'SELECT `users`.* FROM `users` WHERE `users`.`profile_id` = 1 AND `users`.`id` = 1 LIMIT 1',
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).find(1).id
      end
    end
  end
end