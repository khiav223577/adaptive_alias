require 'test_helper'

class StiUserModelQueryingTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
  end

  def test_select_old_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
    ]) do
      assert_equal [3, 4], Users::AgentUser.limit(2).select(:profile_id).map(&:profile_id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
      ]) do
        assert_equal [3, 4], Users::AgentUser.limit(2).select(:profile_id).map(&:profile_id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
      ]) do
        assert_equal [3, 4], Users::AgentUser.limit(2).select(:profile_id).map(&:profile_id)
      end
    end
  end

  def test_select_new_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
    ]) do
      assert_equal [3, 4], Users::AgentUser.limit(2).select(:profile_id_new).map(&:profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
      ]) do
        assert_equal [3, 4], Users::AgentUser.limit(2).select(:profile_id_new).map(&:profile_id_new)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
      ]) do
        assert_equal [3, 4], Users::AgentUser.limit(2).select(:profile_id_new).map(&:profile_id_new)
      end
    end
  end

  def test_pluck_old_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser'",
    ]) do
      assert_equal [3, 4], Users::AgentUser.pluck(:profile_id).first(2)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser'",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser'",
      ]) do
        assert_equal [3, 4], Users::AgentUser.pluck(:profile_id).first(2)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser'",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser'",
      ]) do
        assert_equal [3, 4], Users::AgentUser.pluck(:profile_id).first(2)
      end
    end
  end

  def test_pluck_new_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser'",
    ]) do
      assert_equal [3, 4], Users::AgentUser.pluck(:profile_id_new).first(2)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser'",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser'",
      ]) do
        assert_equal [3, 4], Users::AgentUser.pluck(:profile_id_new).first(2)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser'",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser'",
      ]) do
        assert_equal [3, 4], Users::AgentUser.pluck(:profile_id_new).first(2)
      end
    end
  end

  def test_relation_pluck_old_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
    ]) do
      assert_equal [3, 4], Users::AgentUser.limit(2).pluck(:profile_id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
      ]) do
        assert_equal [3, 4], Users::AgentUser.limit(2).pluck(:profile_id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
      ]) do
        assert_equal [3, 4], Users::AgentUser.limit(2).pluck(:profile_id)
      end
    end
  end

  def test_relation_pluck_new_column
    assert_queries([
      "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
    ]) do
      assert_equal [3, 4], Users::AgentUser.limit(2).pluck(:profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
      ]) do
        assert_equal [3, 4], Users::AgentUser.limit(2).pluck(:profile_id_new)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
        "SELECT `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' LIMIT 2",
      ]) do
        assert_equal [3, 4], Users::AgentUser.limit(2).pluck(:profile_id_new)
      end
    end
  end

  def test_find_by_old_column
    assert_queries([
      "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
    ]) do
      assert_equal 3, Users::AgentUser.find_by(profile_id: 3).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.find_by(profile_id: 3).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.find_by(profile_id: 3).id
      end
    end
  end

  def test_find_by_new_column
    assert_queries([
      "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
    ]) do
      assert_equal 3, Users::AgentUser.find_by(profile_id_new: 3).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.find_by(profile_id_new: 3).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.find_by(profile_id_new: 3).id
      end
    end
  end

  def test_relation_find_by_old_column
    assert_queries([
      "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
    ]) do
      assert_equal 3, Users::AgentUser.limit(1).find_by(profile_id: 3).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.limit(1).find_by(profile_id: 3).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.limit(1).find_by(profile_id: 3).id
      end
    end
  end

  def test_relation_find_by_new_column
    assert_queries([
      "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
    ]) do
      assert_equal 3, Users::AgentUser.limit(1).find_by(profile_id_new: 3).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.limit(1).find_by(profile_id_new: 3).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.limit(1).find_by(profile_id_new: 3).id
      end
    end
  end

  def test_relation_find_old_column
    assert_queries([
      "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 AND `users`.`id` = 3 LIMIT 1",
    ]) do
      assert_equal 3, Users::AgentUser.where(profile_id: 3).find(3).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 AND `users`.`id` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 AND `users`.`id` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.where(profile_id: 3).find(3).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 AND `users`.`id` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 AND `users`.`id` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.where(profile_id: 3).find(3).id
      end
    end
  end

  def test_relation_find_new_column
    assert_queries([
      "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 AND `users`.`id` = 3 LIMIT 1",
    ]) do
      assert_equal 3, Users::AgentUser.where(profile_id_new: 3).find(3).id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 AND `users`.`id` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 AND `users`.`id` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.where(profile_id_new: 3).find(3).id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 AND `users`.`id` = 3 LIMIT 1",
        "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 AND `users`.`id` = 3 LIMIT 1",
      ]) do
        assert_equal 3, Users::AgentUser.where(profile_id_new: 3).find(3).id
      end
    end
  end

  def test_filter_and_count
    assert_queries([
      "SELECT COUNT(*) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
    ]) do
      assert_equal 1, Users::AgentUser.where(profile_id_new: 3).count
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT COUNT(*) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
        "SELECT COUNT(*) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3",
      ]) do
        assert_equal 1, Users::AgentUser.where(profile_id_new: 3).count
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT COUNT(*) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3",
        "SELECT COUNT(*) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
      ]) do
        assert_equal 1, Users::AgentUser.where(profile_id_new: 3).count
      end
    end
  end

  def test_group_and_count
    assert_queries([
      "SELECT COUNT(*) AS #{alias_name_wrapping('count_all')}, `users`.`profile_id` AS #{alias_name_wrapping('users_profile_id')} FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`id` = 3 GROUP BY `users`.`profile_id`",
    ]) do
      assert_equal({ 3 => 1 }, Users::AgentUser.where(id: 3).group(:profile_id_new).count)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT COUNT(*) AS #{alias_name_wrapping('count_all')}, `users`.`profile_id` AS #{alias_name_wrapping('users_profile_id')} FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`id` = 3 GROUP BY `users`.`profile_id`",
        "SELECT COUNT(*) AS #{alias_name_wrapping('count_all')}, `users`.`profile_id_new` AS #{alias_name_wrapping('users_profile_id_new')} FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`id` = 3 GROUP BY `users`.`profile_id_new`",
      ]) do
        assert_equal({ 3 => 1 }, Users::AgentUser.where(id: 3).group(:profile_id_new).count)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT COUNT(*) AS #{alias_name_wrapping('count_all')}, `users`.`profile_id_new` AS #{alias_name_wrapping('users_profile_id_new')} FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`id` = 3 GROUP BY `users`.`profile_id_new`",
        "SELECT COUNT(*) AS #{alias_name_wrapping('count_all')}, `users`.`profile_id` AS #{alias_name_wrapping('users_profile_id')} FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`id` = 3 GROUP BY `users`.`profile_id`",
      ]) do
        assert_equal({ 3 => 1 }, Users::AgentUser.where(id: 3).group(:profile_id_new).count)
      end
    end
  end

  def test_filter_and_sum
    assert_queries([
      "SELECT SUM(`users`.`id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
    ]) do
      assert_equal 3, Users::AgentUser.where(profile_id_new: 3).sum(:id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT SUM(`users`.`id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
        "SELECT SUM(`users`.`id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3",
      ]) do
        assert_equal 3, Users::AgentUser.where(profile_id_new: 3).sum(:id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT SUM(`users`.`id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3",
        "SELECT SUM(`users`.`id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
      ]) do
        assert_equal 3, Users::AgentUser.where(profile_id_new: 3).sum(:id)
      end
    end
  end

  def test_sum_alias_column
    assert_queries([
      "SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`id` = 3",
    ]) do
      assert_equal 3, Users::AgentUser.where(id: 3).sum(:profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`id` = 3",
        "SELECT SUM(`users`.`profile_id_new`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`id` = 3",
      ]) do
        assert_equal 3, Users::AgentUser.where(id: 3).sum(:profile_id_new)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT SUM(`users`.`profile_id_new`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`id` = 3",
        "SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`id` = 3",
      ]) do
        assert_equal 3, Users::AgentUser.where(id: 3).sum(:profile_id_new)
      end
    end
  end

  def test_filter_and_sum_alias_column
    assert_queries([
      "SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
    ]) do
      assert_equal 3, Users::AgentUser.where(profile_id_new: 3).sum(:profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
        "SELECT SUM(`users`.`profile_id_new`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3",
      ]) do
        assert_equal 3, Users::AgentUser.where(profile_id_new: 3).sum(:profile_id_new)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT SUM(`users`.`profile_id_new`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3",
        "SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
      ]) do
        assert_equal 3, Users::AgentUser.where(profile_id_new: 3).sum(:profile_id_new)
      end
    end
  end

  def test_or_query
    assert_queries([
      "SELECT COUNT(*) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND (`users`.`profile_id` = 3 OR `users`.`profile_id` = 4)",
    ]) do
      assert_equal 2, Users::AgentUser.where(profile_id_new: 3).or(Users::AgentUser.where(profile_id: 4)).count
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT COUNT(*) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND (`users`.`profile_id` = 3 OR `users`.`profile_id` = 4)",
        "SELECT COUNT(*) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND (`users`.`profile_id_new` = 3 OR `users`.`profile_id_new` = 4)",
      ]) do
        assert_equal 2, Users::AgentUser.where(profile_id_new: 3).or(Users::AgentUser.where(profile_id: 4)).count
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT COUNT(*) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND (`users`.`profile_id_new` = 3 OR `users`.`profile_id_new` = 4)",
        "SELECT COUNT(*) FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND (`users`.`profile_id` = 3 OR `users`.`profile_id` = 4)",
      ]) do
        assert_equal 2, Users::AgentUser.where(profile_id_new: 3).or(Users::AgentUser.where(profile_id: 4)).count
      end
    end
  end

  def test_filter_and_update_all
    assert_queries_and_rollback([
      "UPDATE `users` SET `users`.`name` = 'new name' WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
    ]) do
      assert_equal 1, Users::AgentUser.where(profile_id_new: 3).update_all(name: 'new name')
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback([
        "UPDATE `users` SET `users`.`name` = 'new name' WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
        "UPDATE `users` SET `users`.`name` = 'new name' WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3",
      ]) do
        assert_equal 1, Users::AgentUser.where(profile_id_new: 3).update_all(name: 'new name')
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback([
        "UPDATE `users` SET `users`.`name` = 'new name' WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3",
        "UPDATE `users` SET `users`.`name` = 'new name' WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
      ]) do
        assert_equal 1, Users::AgentUser.where(profile_id_new: 3).update_all(name: 'new name')
      end
    end
  end

  def test_filter_and_update_all_aliased_column
    assert_queries_and_rollback([
      "UPDATE `users` SET `users`.`profile_id` = 222 WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
    ]) do
      assert_equal 1, Users::AgentUser.where(profile_id_new: 3).update_all(profile_id: 222)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback([
        "UPDATE `users` SET `users`.`profile_id` = 222 WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
        "UPDATE `users` SET `users`.`profile_id_new` = 222 WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3",
      ]) do
        assert_equal 1, Users::AgentUser.where(profile_id_new: 3).update_all(profile_id: 222)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback([
        "UPDATE `users` SET `users`.`profile_id_new` = 222 WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3",
        "UPDATE `users` SET `users`.`profile_id` = 222 WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3",
      ]) do
        assert_equal 1, Users::AgentUser.where(profile_id_new: 3).update_all(profile_id: 222)
      end
    end
  end

  def test_exists?
    assert_queries([
      "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
    ]) do
      assert_equal true, Users::AgentUser.where(profile_id_new: 3).exists?
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
      ]) do
        assert_equal true, Users::AgentUser.where(profile_id_new: 3).exists?
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
      ]) do
        assert_equal true, Users::AgentUser.where(profile_id_new: 3).exists?
      end
    end
  end

  def test_or_query_exists?
    assert_queries([
      "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND (`users`.`profile_id` = 3 OR `users`.`profile_id` = 4) LIMIT 1",
    ]) do
      assert_equal true, Users::AgentUser.where(profile_id_new: 3).or(Users::AgentUser.where(profile_id: 4)).exists?
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND (`users`.`profile_id` = 3 OR `users`.`profile_id` = 4) LIMIT 1",
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND (`users`.`profile_id_new` = 3 OR `users`.`profile_id_new` = 4) LIMIT 1",
      ]) do
        assert_equal true, Users::AgentUser.where(profile_id_new: 3).or(Users::AgentUser.where(profile_id: 4)).exists?
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND (`users`.`profile_id_new` = 3 OR `users`.`profile_id_new` = 4) LIMIT 1",
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND (`users`.`profile_id` = 3 OR `users`.`profile_id` = 4) LIMIT 1",
      ]) do
        assert_equal true, Users::AgentUser.where(profile_id_new: 3).or(Users::AgentUser.where(profile_id: 4)).exists?
      end
    end
  end

  def test_empty?
    assert_queries([
      "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
    ]) do
      assert_equal false, Users::AgentUser.where(profile_id_new: 3).empty?
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
      ]) do
        assert_equal false, Users::AgentUser.where(profile_id_new: 3).empty?
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
      ]) do
        assert_equal false, Users::AgentUser.where(profile_id_new: 3).empty?
      end
    end
  end

  def test_any?
    assert_queries([
      "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
    ]) do
      assert_equal true, Users::AgentUser.where(profile_id_new: 3).any?
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
      ]) do
        assert_equal true, Users::AgentUser.where(profile_id_new: 3).any?
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id_new` = 3 LIMIT 1",
        "SELECT 1 AS one FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`profile_id` = 3 LIMIT 1",
      ]) do
        assert_equal true, Users::AgentUser.where(profile_id_new: 3).any?
      end
    end
  end

  def test_insert_all_with_old_column
    assert_queries_and_rollback([
      "INSERT INTO `users` (`type`,`name`,`profile_id`) VALUES ('Users::AgentUser', 'New User1', 1), ('Users::AgentUser', 'New User2', 2) ON DUPLICATE KEY UPDATE `type`=`type`",
      "SELECT `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' ORDER BY `users`.`id` DESC LIMIT 2",
    ]) do
      User.insert_all([
        { type: 'Users::AgentUser', name: 'New User1', profile_id: 1 },
        { type: 'Users::AgentUser', name: 'New User2', profile_id: 2 },
      ])

      assert_equal [['New User2', 2], ['New User1', 1]], Users::AgentUser.order(id: :desc).limit(2).pluck(:name, :profile_id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback([
        "INSERT INTO `users` (`type`,`name`,`profile_id`) VALUES ('Users::AgentUser', 'New User1', 1), ('Users::AgentUser', 'New User2', 2) ON DUPLICATE KEY UPDATE `type`=`type`",
        "INSERT INTO `users` (`type`,`name`,`profile_id_new`) VALUES ('Users::AgentUser', 'New User1', 1), ('Users::AgentUser', 'New User2', 2) ON DUPLICATE KEY UPDATE `type`=`type`",
        "SELECT `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' ORDER BY `users`.`id` DESC LIMIT 2",
      ]) do
        User.insert_all([
          { type: 'Users::AgentUser', name: 'New User1', profile_id: 1 },
          { type: 'Users::AgentUser', name: 'New User2', profile_id: 2 },
        ])

        assert_equal [['New User2', 2], ['New User1', 1]], Users::AgentUser.order(id: :desc).limit(2).pluck(:name, :profile_id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback([
        "INSERT INTO `users` (`type`,`name`,`profile_id_new`) VALUES ('Users::AgentUser', 'New User1', 1), ('Users::AgentUser', 'New User2', 2) ON DUPLICATE KEY UPDATE `type`=`type`",
        "INSERT INTO `users` (`type`,`name`,`profile_id`) VALUES ('Users::AgentUser', 'New User1', 1), ('Users::AgentUser', 'New User2', 2) ON DUPLICATE KEY UPDATE `type`=`type`",
        "SELECT `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' ORDER BY `users`.`id` DESC LIMIT 2",
      ]) do
        User.insert_all([
          { type: 'Users::AgentUser', name: 'New User1', profile_id: 1 },
          { type: 'Users::AgentUser', name: 'New User2', profile_id: 2 },
        ])

        assert_equal [['New User2', 2], ['New User1', 1]], Users::AgentUser.order(id: :desc).limit(2).pluck(:name, :profile_id)
      end
    end
  end

  def test_insert_all_with_new_column
    assert_queries_and_rollback([
      "INSERT INTO `users` (`type`,`name`,`profile_id`) VALUES ('Users::AgentUser', 'New User1', 1), ('Users::AgentUser', 'New User2', 2) ON DUPLICATE KEY UPDATE `type`=`type`",
      "SELECT `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' ORDER BY `users`.`id` DESC LIMIT 2",
    ]) do
      User.insert_all([
        { type: 'Users::AgentUser', name: 'New User1', profile_id_new: 1 },
        { type: 'Users::AgentUser', name: 'New User2', profile_id_new: 2 },
      ])

      assert_equal [['New User2', 2], ['New User1', 1]], Users::AgentUser.order(id: :desc).limit(2).pluck(:name, :profile_id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback([
        "INSERT INTO `users` (`type`,`name`,`profile_id`) VALUES ('Users::AgentUser', 'New User1', 1), ('Users::AgentUser', 'New User2', 2) ON DUPLICATE KEY UPDATE `type`=`type`",
        "INSERT INTO `users` (`type`,`name`,`profile_id_new`) VALUES ('Users::AgentUser', 'New User1', 1), ('Users::AgentUser', 'New User2', 2) ON DUPLICATE KEY UPDATE `type`=`type`",
        "SELECT `users`.`name`, `users`.`profile_id_new` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' ORDER BY `users`.`id` DESC LIMIT 2",
      ]) do
        User.insert_all([
          { type: 'Users::AgentUser', name: 'New User1', profile_id_new: 1 },
          { type: 'Users::AgentUser', name: 'New User2', profile_id_new: 2 },
        ])

        assert_equal [['New User2', 2], ['New User1', 1]], Users::AgentUser.order(id: :desc).limit(2).pluck(:name, :profile_id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback([
        "INSERT INTO `users` (`type`,`name`,`profile_id_new`) VALUES ('Users::AgentUser', 'New User1', 1), ('Users::AgentUser', 'New User2', 2) ON DUPLICATE KEY UPDATE `type`=`type`",
        "INSERT INTO `users` (`type`,`name`,`profile_id`) VALUES ('Users::AgentUser', 'New User1', 1), ('Users::AgentUser', 'New User2', 2) ON DUPLICATE KEY UPDATE `type`=`type`",
        "SELECT `users`.`name`, `users`.`profile_id` FROM `users` WHERE `users`.`type` = 'Users::AgentUser' ORDER BY `users`.`id` DESC LIMIT 2",
      ]) do
        User.insert_all([
          { type: 'Users::AgentUser', name: 'New User1', profile_id_new: 1 },
          { type: 'Users::AgentUser', name: 'New User2', profile_id_new: 2 },
        ])

        assert_equal [['New User2', 2], ['New User1', 1]], Users::AgentUser.order(id: :desc).limit(2).pluck(:name, :profile_id)
      end
    end
  end
end
