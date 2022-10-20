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

  def test_filter_and_count
    assert_queries([
      'SELECT COUNT(*) FROM `users` WHERE `users`.`profile_id` = 1',
    ]) do
      assert_equal 1, User.where(profile_id_new: 1).count
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT COUNT(*) FROM `users` WHERE `users`.`profile_id` = 1',
        'SELECT COUNT(*) FROM `users` WHERE `users`.`profile_id_new` = 1',
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).count
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT COUNT(*) FROM `users` WHERE `users`.`profile_id_new` = 1',
        'SELECT COUNT(*) FROM `users` WHERE `users`.`profile_id` = 1',
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).count
      end
    end
  end

  def test_group_and_count
    assert_queries([
      "SELECT COUNT(*) AS #{alias_name_wrapping('count_all')}, `users`.`profile_id` AS #{alias_name_wrapping('users_profile_id')} FROM `users` WHERE `users`.`id` = 1 GROUP BY `users`.`profile_id`",
    ]) do
      assert_equal({ 1 => 1 }, User.where(id: 1).group(:profile_id_new).count)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT COUNT(*) AS #{alias_name_wrapping('count_all')}, `users`.`profile_id` AS #{alias_name_wrapping('users_profile_id')} FROM `users` WHERE `users`.`id` = 1 GROUP BY `users`.`profile_id`",
        "SELECT COUNT(*) AS #{alias_name_wrapping('count_all')}, `users`.`profile_id_new` AS #{alias_name_wrapping('users_profile_id_new')} FROM `users` WHERE `users`.`id` = 1 GROUP BY `users`.`profile_id_new`",
      ]) do
        assert_equal({ 1 => 1 }, User.where(id: 1).group(:profile_id_new).count)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        "SELECT COUNT(*) AS #{alias_name_wrapping('count_all')}, `users`.`profile_id_new` AS #{alias_name_wrapping('users_profile_id_new')} FROM `users` WHERE `users`.`id` = 1 GROUP BY `users`.`profile_id_new`",
        "SELECT COUNT(*) AS #{alias_name_wrapping('count_all')}, `users`.`profile_id` AS #{alias_name_wrapping('users_profile_id')} FROM `users` WHERE `users`.`id` = 1 GROUP BY `users`.`profile_id`",
      ]) do
        assert_equal({ 1 => 1 }, User.where(id: 1).group(:profile_id_new).count)
      end
    end
  end

  def test_filter_and_sum
    assert_queries([
      'SELECT SUM(`users`.`id`) FROM `users` WHERE `users`.`profile_id` = 1',
    ]) do
      assert_equal 1, User.where(profile_id_new: 1).sum(:id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT SUM(`users`.`id`) FROM `users` WHERE `users`.`profile_id` = 1',
        'SELECT SUM(`users`.`id`) FROM `users` WHERE `users`.`profile_id_new` = 1',
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).sum(:id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT SUM(`users`.`id`) FROM `users` WHERE `users`.`profile_id_new` = 1',
        'SELECT SUM(`users`.`id`) FROM `users` WHERE `users`.`profile_id` = 1',
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).sum(:id)
      end
    end
  end

  def test_sum_alias_column
    assert_queries([
      'SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`id` = 1',
    ]) do
      assert_equal 1, User.where(id: 1).sum(:profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`id` = 1',
        'SELECT SUM(`users`.`profile_id_new`) FROM `users` WHERE `users`.`id` = 1',
      ]) do
        assert_equal 1, User.where(id: 1).sum(:profile_id_new)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT SUM(`users`.`profile_id_new`) FROM `users` WHERE `users`.`id` = 1',
        'SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`id` = 1',
      ]) do
        assert_equal 1, User.where(id: 1).sum(:profile_id_new)
      end
    end
  end

  def test_filter_and_sum_alias_column
    assert_queries([
      'SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`profile_id` = 1',
    ]) do
      assert_equal 1, User.where(profile_id_new: 1).sum(:profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`profile_id` = 1',
        'SELECT SUM(`users`.`profile_id_new`) FROM `users` WHERE `users`.`profile_id_new` = 1',
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).sum(:profile_id_new)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries([
        'SELECT SUM(`users`.`profile_id_new`) FROM `users` WHERE `users`.`profile_id_new` = 1',
        'SELECT SUM(`users`.`profile_id`) FROM `users` WHERE `users`.`profile_id` = 1',
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).sum(:profile_id_new)
      end
    end
  end

  def test_or_query
    assert_queries([
      'SELECT COUNT(*) FROM `users` WHERE (`users`.`profile_id` = 1 OR `users`.`profile_id` = 2)',
    ]) do
      assert_equal 2, User.where(profile_id_new: 1).or(User.where(profile_id: 2)).count
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT COUNT(*) FROM `users` WHERE (`users`.`profile_id` = 1 OR `users`.`profile_id` = 2)',
        'SELECT COUNT(*) FROM `users` WHERE (`users`.`profile_id_new` = 1 OR `users`.`profile_id_new` = 2)',
      ]) do
        assert_equal 2, User.where(profile_id_new: 1).or(User.where(profile_id: 2)).count
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        'SELECT COUNT(*) FROM `users` WHERE (`users`.`profile_id_new` = 1 OR `users`.`profile_id_new` = 2)',
        'SELECT COUNT(*) FROM `users` WHERE (`users`.`profile_id` = 1 OR `users`.`profile_id` = 2)',
      ]) do
        assert_equal 2, User.where(profile_id_new: 1).or(User.where(profile_id: 2)).count
      end
    end
  end

  def test_filter_and_update_all
    assert_queries_and_rollback([
      "UPDATE `users` SET `users`.`name` = 'new name' WHERE `users`.`profile_id` = 1",
    ]) do
      assert_equal 1, User.where(profile_id_new: 1).update_all(name: 'new name')
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback([
        "UPDATE `users` SET `users`.`name` = 'new name' WHERE `users`.`profile_id` = 1",
        "UPDATE `users` SET `users`.`name` = 'new name' WHERE `users`.`profile_id_new` = 1",
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).update_all(name: 'new name')
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback([
        "UPDATE `users` SET `users`.`name` = 'new name' WHERE `users`.`profile_id_new` = 1",
        "UPDATE `users` SET `users`.`name` = 'new name' WHERE `users`.`profile_id` = 1",
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).update_all(name: 'new name')
      end
    end
  end

  def test_filter_and_update_all_aliased_column
    assert_queries_and_rollback([
      'UPDATE `users` SET `users`.`profile_id` = 222 WHERE `users`.`profile_id` = 1',
    ]) do
      assert_equal 1, User.where(profile_id_new: 1).update_all(profile_id: 222)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback([
        'UPDATE `users` SET `users`.`profile_id` = 222 WHERE `users`.`profile_id` = 1',
        'UPDATE `users` SET `users`.`profile_id_new` = 222 WHERE `users`.`profile_id_new` = 1',
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).update_all(profile_id: 222)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback([
        'UPDATE `users` SET `users`.`profile_id_new` = 222 WHERE `users`.`profile_id_new` = 1',
        'UPDATE `users` SET `users`.`profile_id` = 222 WHERE `users`.`profile_id` = 1',
      ]) do
        assert_equal 1, User.where(profile_id_new: 1).update_all(profile_id: 222)
      end
    end
  end

  def test_exists?
    assert_queries([
      'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
    ]) do
      assert_equal true, User.where(profile_id_new: 1).exists?
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
      ]) do
        assert_equal true, User.where(profile_id_new: 1).exists?
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
      ]) do
        assert_equal true, User.where(profile_id_new: 1).exists?
      end
    end
  end

  def test_or_query_exists?
    assert_queries([
      'SELECT 1 AS one FROM `users` WHERE (`users`.`profile_id` = 1 OR `users`.`profile_id` = 2) LIMIT 1',
    ]) do
      assert_equal true, User.where(profile_id_new: 1).or(User.where(profile_id: 2)).exists?
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT 1 AS one FROM `users` WHERE (`users`.`profile_id` = 1 OR `users`.`profile_id` = 2) LIMIT 1',
        'SELECT 1 AS one FROM `users` WHERE (`users`.`profile_id_new` = 1 OR `users`.`profile_id_new` = 2) LIMIT 1',
      ]) do
        assert_equal true, User.where(profile_id_new: 1).or(User.where(profile_id: 2)).exists?
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        'SELECT 1 AS one FROM `users` WHERE (`users`.`profile_id_new` = 1 OR `users`.`profile_id_new` = 2) LIMIT 1',
        'SELECT 1 AS one FROM `users` WHERE (`users`.`profile_id` = 1 OR `users`.`profile_id` = 2) LIMIT 1',
      ]) do
        assert_equal true, User.where(profile_id_new: 1).or(User.where(profile_id: 2)).exists?
      end
    end
  end

  def test_empty?
    assert_queries([
      'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
    ]) do
      assert_equal false, User.where(profile_id_new: 1).empty?
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
      ]) do
        assert_equal false, User.where(profile_id_new: 1).empty?
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
      ]) do
        assert_equal false, User.where(profile_id_new: 1).empty?
      end
    end
  end

  def test_any?
    assert_queries([
      'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
    ]) do
      assert_equal true, User.where(profile_id_new: 1).any?
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
      ]) do
        assert_equal true, User.where(profile_id_new: 1).any?
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id_new` = 1 LIMIT 1',
        'SELECT 1 AS one FROM `users` WHERE `users`.`profile_id` = 1 LIMIT 1',
      ]) do
        assert_equal true, User.where(profile_id_new: 1).any?
      end
    end
  end

  def test_insert_all_with_old_column
    assert_queries_and_rollback([
      "INSERT INTO `users` (`name`,`profile_id`) VALUES ('New User1', 1), ('New User2', 2) ON DUPLICATE KEY UPDATE `name`=`name`",
      'SELECT `users`.`name`, `users`.`profile_id` FROM `users` ORDER BY `users`.`id` DESC LIMIT 2',
    ]) do
      User.insert_all([
        { name: 'New User1', profile_id: 1 },
        { name: 'New User2', profile_id: 2 },
      ])

      assert_equal [['New User2', 2], ['New User1', 1]], User.order(id: :desc).limit(2).pluck(:name, :profile_id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback([
        "INSERT INTO `users` (`name`,`profile_id`) VALUES ('New User1', 1), ('New User2', 2) ON DUPLICATE KEY UPDATE `name`=`name`",
        "INSERT INTO `users` (`name`,`profile_id_new`) VALUES ('New User1', 1), ('New User2', 2) ON DUPLICATE KEY UPDATE `name`=`name`",
        'SELECT `users`.`name`, `users`.`profile_id_new` FROM `users` ORDER BY `users`.`id` DESC LIMIT 2',
      ]) do
        User.insert_all([
          { name: 'New User1', profile_id: 1 },
          { name: 'New User2', profile_id: 2 },
        ])

        assert_equal [['New User2', 2], ['New User1', 1]], User.order(id: :desc).limit(2).pluck(:name, :profile_id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback([
        "INSERT INTO `users` (`name`,`profile_id_new`) VALUES ('New User1', 1), ('New User2', 2) ON DUPLICATE KEY UPDATE `name`=`name`",
        "INSERT INTO `users` (`name`,`profile_id`) VALUES ('New User1', 1), ('New User2', 2) ON DUPLICATE KEY UPDATE `name`=`name`",
        'SELECT `users`.`name`, `users`.`profile_id` FROM `users` ORDER BY `users`.`id` DESC LIMIT 2',
      ]) do
        User.insert_all([
          { name: 'New User1', profile_id: 1 },
          { name: 'New User2', profile_id: 2 },
        ])

        assert_equal [['New User2', 2], ['New User1', 1]], User.order(id: :desc).limit(2).pluck(:name, :profile_id)
      end
    end
  end

  def test_insert_all_with_new_column
    assert_queries_and_rollback([
      "INSERT INTO `users` (`name`,`profile_id`) VALUES ('New User1', 1), ('New User2', 2) ON DUPLICATE KEY UPDATE `name`=`name`",
      'SELECT `users`.`name`, `users`.`profile_id` FROM `users` ORDER BY `users`.`id` DESC LIMIT 2',
    ]) do
      User.insert_all([
        { name: 'New User1', profile_id_new: 1 },
        { name: 'New User2', profile_id_new: 2 },
      ])

      assert_equal [['New User2', 2], ['New User1', 1]], User.order(id: :desc).limit(2).pluck(:name, :profile_id_new)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback([
        "INSERT INTO `users` (`name`,`profile_id`) VALUES ('New User1', 1), ('New User2', 2) ON DUPLICATE KEY UPDATE `name`=`name`",
        "INSERT INTO `users` (`name`,`profile_id_new`) VALUES ('New User1', 1), ('New User2', 2) ON DUPLICATE KEY UPDATE `name`=`name`",
        'SELECT `users`.`name`, `users`.`profile_id_new` FROM `users` ORDER BY `users`.`id` DESC LIMIT 2',
      ]) do
        User.insert_all([
          { name: 'New User1', profile_id_new: 1 },
          { name: 'New User2', profile_id_new: 2 },
        ])

        assert_equal [['New User2', 2], ['New User1', 1]], User.order(id: :desc).limit(2).pluck(:name, :profile_id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback([
        "INSERT INTO `users` (`name`,`profile_id_new`) VALUES ('New User1', 1), ('New User2', 2) ON DUPLICATE KEY UPDATE `name`=`name`",
        "INSERT INTO `users` (`name`,`profile_id`) VALUES ('New User1', 1), ('New User2', 2) ON DUPLICATE KEY UPDATE `name`=`name`",
        'SELECT `users`.`name`, `users`.`profile_id` FROM `users` ORDER BY `users`.`id` DESC LIMIT 2',
      ]) do
        User.insert_all([
          { name: 'New User1', profile_id_new: 1 },
          { name: 'New User2', profile_id_new: 2 },
        ])

        assert_equal [['New User2', 2], ['New User1', 1]], User.order(id: :desc).limit(2).pluck(:name, :profile_id)
      end
    end
  end
end
