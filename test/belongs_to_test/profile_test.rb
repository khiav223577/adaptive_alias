require 'test_helper'

class ProfileTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
  end

  def test_access
    user = User.find_by(name: 'Catty')
    profile_id = user.profile_id

    assert_queries([
      "SELECT `profiles`.* FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
    ]) do
      assert_equal 'B1234', user.profile.id_number
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.* FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal 'B1234', user.profile.id_number
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.* FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal 'B1234', user.profile.id_number
      end
    end
  end

  def test_association_scope_pick
    user = User.find_by(name: 'Catty')
    profile_id = user.profile_id

    assert_queries([
      "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
    ]) do
      assert_equal 'B1234', user.association(:profile).send(:association_scope).pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal 'B1234', user.association(:profile).send(:association_scope).pick(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal 'B1234', user.association(:profile).send(:association_scope).pick(:id_number)
      end
    end
  end

  def test_association_scope_pluck
    user = User.find_by(name: 'Catty')
    profile_id = user.profile_id

    assert_queries([
      "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
    ]) do
      assert_equal 'B1234', user.association(:profile).send(:association_scope).pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal ['B1234'], user.association(:profile).send(:association_scope).pluck(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = User.find_by(name: 'Catty')

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal ['B1234'], user.association(:profile).send(:association_scope).pluck(:id_number)
      end
    end
  end

  def test_destroy
    user = User.find_by(name: 'Catty')
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

      user = User.find_by(name: 'Catty')
      profile = user.profile

      assert_queries([
        "DELETE FROM `profiles` WHERE `profiles`.`id` = #{profile.id}",
      ]) do
        profile.destroy!
      end

      user.create_profile(profile.as_json)

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = User.find_by(name: 'Catty')
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
      "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' LIMIT 1",
    ]) do
      assert_equal 'B1234', User.joins(:profile).where(name: 'Catty').pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', User.joins(:profile).where(name: 'Catty').pick(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', User.joins(:profile).where(name: 'Catty').pick(:id_number)
      end
    end
  end

  def test_pluck_with_left_join
    assert_queries([
      "SELECT `id_number` FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' LIMIT 1",
    ]) do
      assert_equal 'B1234', User.left_joins(:profile).where(name: 'Catty').pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `id_number` FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `id_number` FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', User.left_joins(:profile).where(name: 'Catty').pick(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `id_number` FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `id_number` FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', User.left_joins(:profile).where(name: 'Catty').pick(:id_number)
      end
    end
  end

  def test_first_with_join
    assert_queries([
      "SELECT `users`.* FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Catty', User.joins(:profile).where(name: 'Catty').first.name
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Catty', User.joins(:profile).where(name: 'Catty').first.name
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Catty', User.joins(:profile).where(name: 'Catty').first.name
      end
    end
  end

  def test_first_with_left_join
    assert_queries([
      "SELECT `users`.* FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Catty', User.left_joins(:profile).where(name: 'Catty').first.name
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Catty', User.left_joins(:profile).where(name: 'Catty').first.name
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Catty', User.left_joins(:profile).where(name: 'Catty').first.name
      end
    end
  end

  def test_pluck_with_join_reversely
    assert_queries([
      "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
    ]) do
      assert_equal 'B1234', Profile.joins(:user).merge(User.where(name: 'Catty')).pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', Profile.joins(:user).merge(User.where(name: 'Catty')).pick(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', Profile.joins(:user).merge(User.where(name: 'Catty')).pick(:id_number)
      end
    end
  end

  def test_pluck_with_left_join_reversely
    assert_queries([
      "SELECT `profiles`.`id_number` FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
    ]) do
      assert_equal 'B1234', Profile.left_joins(:user).merge(User.where(name: 'Catty')).pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `profiles`.`id_number` FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', Profile.left_joins(:user).merge(User.where(name: 'Catty')).pick(:id_number)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `profiles`.`id_number` FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', Profile.left_joins(:user).merge(User.where(name: 'Catty')).pick(:id_number)
      end
    end
  end

  def test_first_with_join_reversely
    assert_queries([
      "SELECT `profiles`.* FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `profiles`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'B1234', Profile.joins(:user).merge(User.where(name: 'Catty')).first.id_number
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `profiles`.* FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `profiles`.`id` ASC LIMIT 1",
        "SELECT `profiles`.* FROM `profiles` INNER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `profiles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'B1234', Profile.joins(:user).merge(User.where(name: 'Catty')).first.id_number
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `profiles`.* FROM `profiles` INNER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `profiles`.`id` ASC LIMIT 1",
        "SELECT `profiles`.* FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `profiles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'B1234', Profile.joins(:user).merge(User.where(name: 'Catty')).first.id_number
      end
    end
  end

  def test_first_with_left_join_reversely
    assert_queries([
      "SELECT `profiles`.* FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `profiles`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'B1234', Profile.left_joins(:user).merge(User.where(name: 'Catty')).first.id_number
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `profiles`.* FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `profiles`.`id` ASC LIMIT 1",
        "SELECT `profiles`.* FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `profiles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'B1234', Profile.left_joins(:user).merge(User.where(name: 'Catty')).first.id_number
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `profiles`.* FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `profiles`.`id` ASC LIMIT 1",
        "SELECT `profiles`.* FROM `profiles` LEFT OUTER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `profiles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'B1234', Profile.left_joins(:user).merge(User.where(name: 'Catty')).first.id_number
      end
    end
  end

  def test_create_by_association
    profile = Profile.first

    new_user = nil
    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      new_user = User.create!(name: 'New User', profile: profile)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', 1)",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('New User', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        new_user = User.create!(name: 'New User', profile: profile)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('New User', 1)",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        new_user = User.create!(name: 'New User', profile: profile)
      end
    end
  end

  def test_nested_create_by_association
    new_user = nil
    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `profiles` (`id_number`) VALUES ('New1234')",
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', #{new_user.profile_id})",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      new_user = User.create!(name: 'New User', profile: Profile.new(id_number: 'New1234'))
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `profiles` (`id_number`) VALUES ('New1234')",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', #{new_user.profile_id})",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('New User', #{new_user.profile_id})",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        new_user = User.create!(name: 'New User', profile: Profile.new(id_number: 'New1234'))
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `profiles` (`id_number`) VALUES ('New1234')",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('New User', #{new_user.profile_id})",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', #{new_user.profile_id})",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        new_user = User.create!(name: 'New User', profile: Profile.new(id_number: 'New1234'))
      end
    end
  end

  def test_create_by_old_column
    profile = Profile.first

    new_user = nil
    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      new_user = User.create!(name: 'New User', profile_id: profile.id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', 1)",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('New User', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        new_user = User.create!(name: 'New User', profile_id: profile.id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('New User', 1)",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        new_user = User.create!(name: 'New User', profile_id: profile.id)
      end
    end
  end

  def test_create_by_new_column
    profile = Profile.first

    new_user = nil
    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      new_user = User.create!(name: 'New User', profile_id_new: profile.id)
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', 1)",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('New User', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        new_user = User.create!(name: 'New User', profile_id_new: profile.id)
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('New User', 1)",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('New User', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{new_user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        new_user = User.create!(name: 'New User', profile_id_new: profile.id)
      end
    end
  end
end
