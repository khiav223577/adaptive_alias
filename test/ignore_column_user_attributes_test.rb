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

  def test_create
    user = nil

    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::IgnoreColumnUser', 'test', 1234)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      user = Users::IgnoreColumnUser.new(name: 'test', profile_id: 1234)
      user.save!
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::IgnoreColumnUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::IgnoreColumnUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user = Users::IgnoreColumnUser.new(name: 'test', profile_id: 1234)
        user.save!
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::IgnoreColumnUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::IgnoreColumnUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user = Users::IgnoreColumnUser.new(name: 'test', profile_id: 1234)
        user.save!
      end
    end
  end

  def test_create_multi
    user1 = nil
    user2 = nil
    user3 = nil
    profile = Profile.find(1)

    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::IgnoreColumnUser', 'test', 1234)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::IgnoreColumnUser', 'test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::IgnoreColumnUser', 'test', 2222)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      user1 = Users::IgnoreColumnUser.new(name: 'test', profile_id: 1234)
      user2 = Users::IgnoreColumnUser.new(name: 'test', profile_id: profile.id)
      user3 = Users::IgnoreColumnUser.new(name: 'test', profile_id_new: 2222)
      user1.save!
      user2.save!
      user3.save!
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::IgnoreColumnUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::IgnoreColumnUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::IgnoreColumnUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::IgnoreColumnUser', 'test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1 = Users::IgnoreColumnUser.new(name: 'test', profile_id: 1234)
        user2 = Users::IgnoreColumnUser.new(name: 'test', profile_id: profile.id)
        user3 = Users::IgnoreColumnUser.new(name: 'test', profile_id_new: 2222)
        user1.save!
        user2.save!
        user3.save!
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`type`, `name`, `profile_id_new`) VALUES ('Users::IgnoreColumnUser', 'test', 1234)",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::IgnoreColumnUser', 'test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::IgnoreColumnUser', 'test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`type`, `name`, `profile_id`) VALUES ('Users::IgnoreColumnUser', 'test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1 = Users::IgnoreColumnUser.new(name: 'test', profile_id: 1234)
        user2 = Users::IgnoreColumnUser.new(name: 'test', profile_id: profile.id)
        user3 = Users::IgnoreColumnUser.new(name: 'test', profile_id_new: 2222)
        user1.save!
        user2.save!
        user3.save!
      end
    end
  end
end
