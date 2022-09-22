require 'test_helper'

class StiUserProfileTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
  end

  def test_access
    user = Users::AgentUser.find_by(name: 'Pepper')
    profile_id = user.profile_id

    assert_queries([
      "SELECT `profiles`.* FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
    ]) do
      assert_equal 'C1234', user.profile.id_number
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `profiles`.* FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal 'C1234', user.profile.id_number
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `profiles`.* FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal 'C1234', user.profile.id_number
      end
    end
  end

  def test_association_scope_pick
    user = Users::AgentUser.find_by(name: 'Pepper')
    profile_id = user.profile_id

    assert_queries([
      "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
    ]) do
      assert_equal 'C1234', user.association(:profile).send(:association_scope).pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal 'C1234', user.association(:profile).send(:association_scope).pick(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal 'C1234', user.association(:profile).send(:association_scope).pick(:id_number)
      end
    end
  end

  def test_association_scope_pluck
    user = Users::AgentUser.find_by(name: 'Pepper')
    profile_id = user.profile_id

    assert_queries([
      "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
    ]) do
      assert_equal 'C1234', user.association(:profile).send(:association_scope).pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal ['C1234'], user.association(:profile).send(:association_scope).pluck(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = Users::AgentUser.find_by(name: 'Pepper')

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal ['C1234'], user.association(:profile).send(:association_scope).pluck(:id_number)
      end
    end
  end

  def test_destroy
    user = Users::AgentUser.find_by(name: 'Pepper')
    profile = user.profile

    assert_queries([
      "DELETE FROM `profiles` WHERE `profiles`.`id` = #{profile.id}",
    ]) do
      profile.destroy!
    end

    user.create_profile(profile.as_json)

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      user = Users::AgentUser.find_by(name: 'Pepper')
      profile = user.profile

      assert_queries([
        "DELETE FROM `profiles` WHERE `profiles`.`id` = #{profile.id}",
      ]) do
        profile.destroy!
      end

      user.create_profile(profile.as_json)

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      profile = user.profile

      assert_queries([
        "DELETE FROM `profiles` WHERE `profiles`.`id` = #{profile.id}",
      ]) do
        profile.destroy!
      end

      user.create_profile(profile.as_json)
    end
  ensure
    user.create_profile(profile.as_json) if user.profile == nil
  end

  def test_pluck_with_join
    assert_queries([
      "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
    ]) do
      assert_equal 'C1234', User.joins(:profile).where(name: 'Pepper').pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Pepper' LIMIT 1",
      ]) do
        assert_equal 'C1234', User.joins(:profile).where(name: 'Pepper').pick(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Pepper' LIMIT 1",
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
      ]) do
        assert_equal 'C1234', User.joins(:profile).where(name: 'Pepper').pick(:id_number)
      end
    end
  end

  def test_pluck_with_left_join
    assert_queries([
      "SELECT `id_number` FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
    ]) do
      assert_equal 'C1234', User.left_joins(:profile).where(name: 'Pepper').pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `id_number` FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
        "SELECT `id_number` FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Pepper' LIMIT 1",
      ]) do
        assert_equal 'C1234', User.left_joins(:profile).where(name: 'Pepper').pick(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `id_number` FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Pepper' LIMIT 1",
        "SELECT `id_number` FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
      ]) do
        assert_equal 'C1234', User.left_joins(:profile).where(name: 'Pepper').pick(:id_number)
      end
    end
  end

  def test_first_with_join
    assert_queries([
      "SELECT `users`.* FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Pepper', User.joins(:profile).where(name: 'Pepper').first.name
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Pepper', User.joins(:profile).where(name: 'Pepper').first.name
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Pepper', User.joins(:profile).where(name: 'Pepper').first.name
      end
    end
  end

  def test_first_with_left_join
    assert_queries([
      "SELECT `users`.* FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Pepper', User.left_joins(:profile).where(name: 'Pepper').first.name
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Pepper', User.left_joins(:profile).where(name: 'Pepper').first.name
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Pepper', User.left_joins(:profile).where(name: 'Pepper').first.name
      end
    end
  end

  def test_pluck_with_join_reversely
    assert_queries([
      "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
    ]) do
      assert_equal 'C1234', Profile.joins(:user).merge(User.where(name: 'Pepper')).pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
      ]) do
        assert_equal 'C1234', Profile.joins(:user).merge(User.where(name: 'Pepper')).pick(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
      ]) do
        assert_equal 'C1234', Profile.joins(:user).merge(User.where(name: 'Pepper')).pick(:id_number)
      end
    end
  end

  def test_pluck_with_left_join_reversely
    assert_queries([
      "SELECT `profiles`.`id_number` FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
    ]) do
      assert_equal 'C1234', Profile.left_joins(:user).merge(User.where(name: 'Pepper')).pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
        "SELECT `profiles`.`id_number` FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
      ]) do
        assert_equal 'C1234', Profile.left_joins(:user).merge(User.where(name: 'Pepper')).pick(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
        "SELECT `profiles`.`id_number` FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' LIMIT 1",
      ]) do
        assert_equal 'C1234', Profile.left_joins(:user).merge(User.where(name: 'Pepper')).pick(:id_number)
      end
    end
  end

  def test_first_with_join_reversely
    assert_queries([
      "SELECT `profiles`.* FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' ORDER BY `profiles`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'C1234', Profile.joins(:user).merge(User.where(name: 'Pepper')).first.id_number
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `profiles`.* FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' ORDER BY `profiles`.`id` ASC LIMIT 1",
        "SELECT `profiles`.* FROM `profiles` INNER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' ORDER BY `profiles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'C1234', Profile.joins(:user).merge(User.where(name: 'Pepper')).first.id_number
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `profiles`.* FROM `profiles` INNER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' ORDER BY `profiles`.`id` ASC LIMIT 1",
        "SELECT `profiles`.* FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' ORDER BY `profiles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'C1234', Profile.joins(:user).merge(User.where(name: 'Pepper')).first.id_number
      end
    end
  end

  def test_first_with_left_join_reversely
    assert_queries([
      "SELECT `profiles`.* FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' ORDER BY `profiles`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'C1234', Profile.left_joins(:user).merge(User.where(name: 'Pepper')).first.id_number
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `profiles`.* FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' ORDER BY `profiles`.`id` ASC LIMIT 1",
        "SELECT `profiles`.* FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' ORDER BY `profiles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'C1234', Profile.left_joins(:user).merge(User.where(name: 'Pepper')).first.id_number
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `profiles`.* FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' ORDER BY `profiles`.`id` ASC LIMIT 1",
        "SELECT `profiles`.* FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Pepper' ORDER BY `profiles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'C1234', Profile.left_joins(:user).merge(User.where(name: 'Pepper')).first.id_number
      end
    end
  end
end
