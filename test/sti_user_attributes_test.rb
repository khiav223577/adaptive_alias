require 'test_helper'

class StiUserAttributesTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
  end

  def test_read
    user = Users::AgentUser.find_by(name: 'Pepper')
    profile_id = user.profile.id

    assert_queries(0) do
      assert_equal profile_id, user.profile_id_new
      assert_equal profile_id, user.profile_id
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
        assert_equal profile_id, user.profile_id
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
        assert_equal profile_id, user.profile_id
      end
    end
  end

  def test_write
    user = Users::AgentUser.find_by(name: 'Pepper')
    assert_queries(0) do
      user.profile_id = 123
      user.profile_id_new = 123
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries(0) do
        user.profile_id = 123
        user.profile_id_new = 123
        assert_equal 123, user.profile_id
        assert_equal 123, user.profile_id_new
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries(0) do
        user.profile_id = 123
        user.profile_id_new = 123
        assert_equal 123, user.profile_id
        assert_equal 123, user.profile_id_new
      end
    end
  end

  def test_read_write
    user = Users::AgentUser.find_by(name: 'Pepper')
    profile_id = user.profile.id

    assert_queries(0) do
      assert_equal profile_id, user.profile_id_new
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      user = Users::AgentUser.find_by(name: 'Pepper')

      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user = Users::AgentUser.find_by(name: 'Pepper')

      assert_queries(0) do
        user.profile_id_new = 123
        assert_equal 123, user.profile_id_new
      end
    end
  end

  def test_create
    user = nil

    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      user = Users::AgentUser.new(name: 'test', profile_id: 1234)
      user.save!
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user = Users::AgentUser.new(name: 'test', profile_id: 1234)
        user.save!
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user = Users::AgentUser.new(name: 'test', profile_id: 1234)
        user.save!
      end
    end
  end

  def test_create_multi
    user1 = nil
    user2 = nil
    user3 = nil
    user4 = nil
    profile = Profile.find(1)

    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 2222)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      user1 = Users::AgentUser.new(name: 'test', profile_id: 1234)
      user2 = Users::AgentUser.new(name: 'test', profile_id: profile.id)
      user3 = Users::AgentUser.new(name: 'test', profile: profile)
      user4 = Users::AgentUser.new(name: 'test', profile_id_new: 2222)
      user1.save!
      user2.save!
      user3.save!
      user4.save!
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1 = Users::AgentUser.new(name: 'test', profile_id: 1234)
        user2 = Users::AgentUser.new(name: 'test', profile_id: profile.id)
        user3 = Users::AgentUser.new(name: 'test', profile: profile)
        user4 = Users::AgentUser.new(name: 'test', profile_id_new: 2222)
        user1.save!
        user2.save!
        user3.save!
        user4.save!
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1 = Users::AgentUser.new(name: 'test', profile_id: 1234)
        user2 = Users::AgentUser.new(name: 'test', profile_id: profile.id)
        user3 = Users::AgentUser.new(name: 'test', profile: profile)
        user4 = Users::AgentUser.new(name: 'test', profile_id_new: 2222)
        user1.save!
        user2.save!
        user3.save!
        user4.save!
      end
    end
  end

  def test_create_multi_with_pre_new
    user1 = nil
    user2 = nil
    user3 = nil
    user4 = nil
    profile = Profile.find(1)

    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 2222)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      user1 = Users::AgentUser.new(name: 'test', profile_id: 1234)
      user2 = Users::AgentUser.new(name: 'test', profile_id: profile.id)
      user3 = Users::AgentUser.new(name: 'test', profile: profile)
      user4 = Users::AgentUser.new(name: 'test', profile_id_new: 2222)
      user1.save!
      user2.save!
      user3.save!
      user4.save!
    end

    3.times do
      # --------- do rename migration ---------
      user1 = Users::AgentUser.new(name: 'test', profile_id: 1234)
      user2 = Users::AgentUser.new(name: 'test', profile_id: profile.id)
      user3 = Users::AgentUser.new(name: 'test', profile: profile)
      user4 = Users::AgentUser.new(name: 'test', profile_id_new: 2222)
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1.save!
        user2.save!
        user3.save!
        user4.save!
      end

      # --------- rollback rename migration ---------
      user1 = Users::AgentUser.new(name: 'test', profile_id: 1234)
      user2 = Users::AgentUser.new(name: 'test', profile_id: profile.id)
      user3 = Users::AgentUser.new(name: 'test', profile: profile)
      user4 = Users::AgentUser.new(name: 'test', profile_id_new: 2222)
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1.save!
        user2.save!
        user3.save!
        user4.save!
      end
    end
  end

  def test_create_multi_with_middle_new
    user1 = nil
    user2 = nil
    user3 = nil
    user4 = nil
    profile = Profile.find(1)

    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 2222)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      user1 = Users::AgentUser.new(name: 'test', profile_id: 1234)
      user2 = Users::AgentUser.new(name: 'test', profile_id: profile.id)
      user3 = Users::AgentUser.new(name: 'test', profile: profile)
      user4 = Users::AgentUser.new(name: 'test', profile_id_new: 2222)
      user1.save!
      user2.save!
      user3.save!
      user4.save!
    end

    3.times do
      user1 = Users::AgentUser.new(name: 'test', profile_id: 1234)
      user2 = Users::AgentUser.new(name: 'test', profile_id: profile.id)
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user3 = Users::AgentUser.new(name: 'test', profile: profile)
        user4 = Users::AgentUser.new(name: 'test', profile_id_new: 2222)
        user1.save!
        user2.save!
        user3.save!
        user4.save!
      end

      # --------- rollback rename migration ---------
      user1 = Users::AgentUser.new(name: 'test', profile_id: 1234)
      user2 = Users::AgentUser.new(name: 'test', profile_id: profile.id)
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::AgentUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::AgentUser', 'test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user3 = Users::AgentUser.new(name: 'test', profile: profile)
        user4 = Users::AgentUser.new(name: 'test', profile_id_new: 2222)
        user1.save!
        user2.save!
        user3.save!
        user4.save!
      end
    end
  end

  def test_update
    user = Users::AgentUser.find_by(name: 'Pepper')

    assert_queries_and_rollback([
      "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user.id}",
      "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
    ]) do
      user.profile_id = 12345
      user.save!
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries_and_rollback(lambda {
        [
          "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user.id}",
          "UPDATE `users` SET `users`.`profile_id_new` = 12345 WHERE `users`.`id` = #{user.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user.profile_id = 12345
        user.save!
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries_and_rollback(lambda {
        [
          "UPDATE `users` SET `users`.`profile_id_new` = 12345 WHERE `users`.`id` = #{user.id}",
          "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user.profile_id = 12345
        user.save!
      end
    end
  end

  def test_update_multi
    user1 = Users::AgentUser.find_by(name: 'Pepper')
    user2 = Users::AgentUser.find_by(name: 'Hachu')

    assert_queries_and_rollback([
      "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
      "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
      "UPDATE `users` SET `users`.`profile_id` = 33333 WHERE `users`.`id` = #{user2.id}",
      "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
    ]) do
      user1.profile_id = 12345
      user2.profile_id = 33333
      user1.save!
      user2.save!
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new
      user1 = Users::AgentUser.find_by(name: 'Pepper')
      user2 = Users::AgentUser.find_by(name: 'Hachu')

      assert_queries_and_rollback(lambda {
        [
          "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
          "UPDATE `users` SET `users`.`profile_id_new` = 12345 WHERE `users`.`id` = #{user1.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "UPDATE `users` SET `users`.`profile_id_new` = 33333 WHERE `users`.`id` = #{user2.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1.profile_id = 12345
        user2.profile_id = 33333
        user1.save!
        user2.save!
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id
      user1 = Users::AgentUser.find_by(name: 'Pepper')
      user2 = Users::AgentUser.find_by(name: 'Hachu')

      assert_queries_and_rollback(lambda {
        [
          "UPDATE `users` SET `users`.`profile_id_new` = 12345 WHERE `users`.`id` = #{user1.id}",
          "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "UPDATE `users` SET `users`.`profile_id` = 33333 WHERE `users`.`id` = #{user2.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1.profile_id = 12345
        user2.profile_id = 33333
        user1.save!
        user2.save!
      end
    end
  end

  def test_update_multi_with_pre_find_by
    user1 = Users::AgentUser.find_by(name: 'Pepper')
    user2 = Users::AgentUser.find_by(name: 'Hachu')

    assert_queries_and_rollback([
      "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
      "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
      "UPDATE `users` SET `users`.`profile_id` = 33333 WHERE `users`.`id` = #{user2.id}",
      "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
    ]) do
      user1.profile_id = 12345
      user2.profile_id = 33333
      user1.save!
      user2.save!
    end

    3.times do
      # --------- do rename migration ---------
      user1 = Users::AgentUser.find_by(name: 'Pepper')
      user2 = Users::AgentUser.find_by(name: 'Hachu')
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
          "UPDATE `users` SET `users`.`profile_id_new` = 12345 WHERE `users`.`id` = #{user1.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "UPDATE `users` SET `users`.`profile_id_new` = 33333 WHERE `users`.`id` = #{user2.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1.profile_id = 12345
        user2.profile_id = 33333
        user1.save!
        user2.save!
      end

      # --------- rollback rename migration ---------
      user1 = Users::AgentUser.find_by(name: 'Pepper')
      user2 = Users::AgentUser.find_by(name: 'Hachu')
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "UPDATE `users` SET `users`.`profile_id_new` = 12345 WHERE `users`.`id` = #{user1.id}",
          "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "UPDATE `users` SET `users`.`profile_id` = 33333 WHERE `users`.`id` = #{user2.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1.profile_id = 12345
        user2.profile_id = 33333
        user1.save!
        user2.save!
      end
    end
  end

  def test_update_multi_with_middle_find_by
    user1 = Users::AgentUser.find_by(name: 'Pepper')
    user2 = Users::AgentUser.find_by(name: 'Hachu')

    assert_queries_and_rollback([
      "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
      "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
      "UPDATE `users` SET `users`.`profile_id` = 33333 WHERE `users`.`id` = #{user2.id}",
      "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
    ]) do
      user1.profile_id = 12345
      user2.profile_id = 33333
      user1.save!
      user2.save!
    end

    3.times do
      # --------- do rename migration ---------
      user1 = Users::AgentUser.find_by(name: 'Pepper')
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' LIMIT 1",
          "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
          "UPDATE `users` SET `users`.`profile_id_new` = 12345 WHERE `users`.`id` = #{user1.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "UPDATE `users` SET `users`.`profile_id_new` = 33333 WHERE `users`.`id` = #{user2.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user2 = Users::AgentUser.find_by(name: 'Hachu')

        user1.profile_id = 12345
        user2.profile_id = 33333
        user1.save!
        user2.save!
      end

      # --------- rollback rename migration ---------
      user1 = Users::AgentUser.find_by(name: 'Pepper')
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "SELECT `users`.* FROM `users` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' LIMIT 1",
          "UPDATE `users` SET `users`.`profile_id_new` = 12345 WHERE `users`.`id` = #{user1.id}",
          "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "UPDATE `users` SET `users`.`profile_id` = 33333 WHERE `users`.`id` = #{user2.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user2 = Users::AgentUser.find_by(name: 'Hachu')

        user1.profile_id = 12345
        user2.profile_id = 33333
        user1.save!
        user2.save!
      end
    end
  end
end
