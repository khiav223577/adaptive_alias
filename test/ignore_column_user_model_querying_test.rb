require 'test_helper'

class IgnoreColumnUserModelQueryingTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
  end

  def test_select_old_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
    ]) do
      assert_equal [5], Users::IgnoreColumnUser.limit(2).select(:profile_id).map(&:profile_id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.limit(2).select(:profile_id).map(&:profile_id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.limit(2).select(:profile_id).map(&:profile_id)
      end
    end
  end

  def test_select_new_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
    ]) do
      assert_equal [5], Users::IgnoreColumnUser.limit(2).select(:profile_id_new).map(&:profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.limit(2).select(:profile_id_new).map(&:profile_id_new)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.limit(2).select(:profile_id_new).map(&:profile_id_new)
      end
    end
  end

  def test_pluck_old_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser'",
    ]) do
      assert_equal [5], Users::IgnoreColumnUser.pluck(:profile_id).first(2)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser'",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser'",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.pluck(:profile_id).first(2)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser'",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser'",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.pluck(:profile_id).first(2)
      end
    end
  end

  def test_pluck_new_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser'",
    ]) do
      assert_equal [5], Users::IgnoreColumnUser.pluck(:profile_id_new).first(2)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser'",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser'",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.pluck(:profile_id_new).first(2)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser'",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser'",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.pluck(:profile_id_new).first(2)
      end
    end
  end

  def test_relation_pluck_old_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
    ]) do
      assert_equal [5], Users::IgnoreColumnUser.limit(2).pluck(:profile_id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.limit(2).pluck(:profile_id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.limit(2).pluck(:profile_id)
      end
    end
  end

  def test_relation_pluck_new_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
    ]) do
      assert_equal [5], Users::IgnoreColumnUser.limit(2).pluck(:profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.limit(2).pluck(:profile_id_new)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' LIMIT 2",
      ]) do
        assert_equal [5], Users::IgnoreColumnUser.limit(2).pluck(:profile_id_new)
      end
    end
  end

  def test_find_by_old_column
    assert_queries([
      "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
    ]) do
      assert_equal 5, Users::IgnoreColumnUser.find_by(profile_id: 5).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.find_by(profile_id: 5).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.find_by(profile_id: 5).id
      end
    end
  end

  def test_find_by_new_column
    assert_queries([
      "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
    ]) do
      assert_equal 5, Users::IgnoreColumnUser.find_by(profile_id_new: 5).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.find_by(profile_id_new: 5).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.find_by(profile_id_new: 5).id
      end
    end
  end

  def test_relation_find_by_old_column
    assert_queries([
      "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
    ]) do
      assert_equal 5, Users::IgnoreColumnUser.limit(1).find_by(profile_id: 5).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.limit(1).find_by(profile_id: 5).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.limit(1).find_by(profile_id: 5).id
      end
    end
  end

  def test_relation_find_by_new_column
    assert_queries([
      "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
    ]) do
      assert_equal 5, Users::IgnoreColumnUser.limit(1).find_by(profile_id_new: 5).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.limit(1).find_by(profile_id_new: 5).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.limit(1).find_by(profile_id_new: 5).id
      end
    end
  end

  def test_relation_find_old_column
    assert_queries([
      "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 AND `users`.`id` = 5 LIMIT 1",
    ]) do
      assert_equal 5, Users::IgnoreColumnUser.where(profile_id: 5).find(5).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 AND `users`.`id` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 AND `users`.`id` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.where(profile_id: 5).find(5).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 AND `users`.`id` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 AND `users`.`id` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.where(profile_id: 5).find(5).id
      end
    end
  end

  def test_relation_find_new_column
    assert_queries([
      "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 AND `users`.`id` = 5 LIMIT 1",
    ]) do
      assert_equal 5, Users::IgnoreColumnUser.where(profile_id: 5).find(5).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 AND `users`.`id` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 AND `users`.`id` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.where(profile_id: 5).find(5).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id_new` = 5 AND `users`.`id` = 5 LIMIT 1",
        "SELECT `users`.`id`, `users`.`type`, `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::IgnoreColumnUser' AND `users`.`profile_id` = 5 AND `users`.`id` = 5 LIMIT 1",
      ]) do
        assert_equal 5, Users::IgnoreColumnUser.where(profile_id: 5).find(5).id
      end
    end
  end
end
