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

  def test_create
    user = nil

    assert_queries_and_rollback(lambda {
      [
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      user = User.new(name: 'test', profile_id: 1234)
      user.save!
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user = User.new(name: 'test', profile_id: 1234)
        user.save!
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1234)",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user = User.new(name: 'test', profile_id: 1234)
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
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 2222)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      user1 = User.new(name: 'test', profile_id: 1234)
      user2 = User.new(name: 'test', profile_id: profile.id)
      user3 = User.new(name: 'test', profile: profile)
      user4 = User.new(name: 'test', profile_id_new: 2222)
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
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1 = User.new(name: 'test', profile_id: 1234)
        user2 = User.new(name: 'test', profile_id: profile.id)
        user3 = User.new(name: 'test', profile: profile)
        user4 = User.new(name: 'test', profile_id_new: 2222)
        user1.save!
        user2.save!
        user3.save!
        user4.save!
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1234)",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1 = User.new(name: 'test', profile_id: 1234)
        user2 = User.new(name: 'test', profile_id: profile.id)
        user3 = User.new(name: 'test', profile: profile)
        user4 = User.new(name: 'test', profile_id_new: 2222)
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
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 2222)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      user1 = User.new(name: 'test', profile_id: 1234)
      user2 = User.new(name: 'test', profile_id: profile.id)
      user3 = User.new(name: 'test', profile: profile)
      user4 = User.new(name: 'test', profile_id_new: 2222)
      user1.save!
      user2.save!
      user3.save!
      user4.save!
    end

    3.times do
      # --------- do rename migration ---------
      user1 = User.new(name: 'test', profile_id: 1234)
      user2 = User.new(name: 'test', profile_id: profile.id)
      user3 = User.new(name: 'test', profile: profile)
      user4 = User.new(name: 'test', profile_id_new: 2222)
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user1.save!
        user2.save!
        user3.save!
        user4.save!
      end

      # --------- rollback rename migration ---------
      user1 = User.new(name: 'test', profile_id: 1234)
      user2 = User.new(name: 'test', profile_id: profile.id)
      user3 = User.new(name: 'test', profile: profile)
      user4 = User.new(name: 'test', profile_id_new: 2222)
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1234)",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 2222)",
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
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
        "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 2222)",
        "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
      ]
    }) do
      user1 = User.new(name: 'test', profile_id: 1234)
      user2 = User.new(name: 'test', profile_id: profile.id)
      user3 = User.new(name: 'test', profile: profile)
      user4 = User.new(name: 'test', profile_id_new: 2222)
      user1.save!
      user2.save!
      user3.save!
      user4.save!
    end

    3.times do
      # --------- do rename migration ---------
      user1 = User.new(name: 'test', profile_id: 1234)
      user2 = User.new(name: 'test', profile_id: profile.id)
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user3 = User.new(name: 'test', profile: profile)
        user4 = User.new(name: 'test', profile_id_new: 2222)
        user1.save!
        user2.save!
        user3.save!
        user4.save!
      end

      # --------- rollback rename migration ---------
      user1 = User.new(name: 'test', profile_id: 1234)
      user2 = User.new(name: 'test', profile_id: profile.id)
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "INSERT INTO `users` (`name`, `profile_id_new`) VALUES ('test', 1234)",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1234)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 1)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user3.id} AND `taggings`.`taggable_type` = 'User'",
          "INSERT INTO `users` (`name`, `profile_id`) VALUES ('test', 2222)",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user4.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user3 = User.new(name: 'test', profile: profile)
        user4 = User.new(name: 'test', profile_id_new: 2222)
        user1.save!
        user2.save!
        user3.save!
        user4.save!
      end
    end
  end

  def test_update
    user = User.find_by(name: 'Catty')

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

      user = User.find_by(name: 'Catty')
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

      user = User.find_by(name: 'Catty')
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
    user1 = User.find_by(name: 'Catty')
    user2 = User.find_by(name: 'Doggy')

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
      user1 = User.find_by(name: 'Catty')
      user2 = User.find_by(name: 'Doggy')

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
      user1 = User.find_by(name: 'Catty')
      user2 = User.find_by(name: 'Doggy')

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
    user1 = User.find_by(name: 'Catty')
    user2 = User.find_by(name: 'Doggy')

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
      user1 = User.find_by(name: 'Catty')
      user2 = User.find_by(name: 'Doggy')
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
      user1 = User.find_by(name: 'Catty')
      user2 = User.find_by(name: 'Doggy')
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
    user1 = User.find_by(name: 'Catty')
    user2 = User.find_by(name: 'Doggy')

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
      user1 = User.find_by(name: 'Catty')
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback(lambda {
        [
          "SELECT `users`.* FROM `users` WHERE `users`.`name` = 'Doggy' LIMIT 1",
          "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
          "UPDATE `users` SET `users`.`profile_id_new` = 12345 WHERE `users`.`id` = #{user1.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "UPDATE `users` SET `users`.`profile_id_new` = 33333 WHERE `users`.`id` = #{user2.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user2 = User.find_by(name: 'Doggy')

        user1.profile_id = 12345
        user2.profile_id = 33333
        user1.save!
        user2.save!
      end

      # --------- rollback rename migration ---------
      user1 = User.find_by(name: 'Catty')
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback(lambda {
        [
          "SELECT `users`.* FROM `users` WHERE `users`.`name` = 'Doggy' LIMIT 1",
          "UPDATE `users` SET `users`.`profile_id_new` = 12345 WHERE `users`.`id` = #{user1.id}",
          "UPDATE `users` SET `users`.`profile_id` = 12345 WHERE `users`.`id` = #{user1.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user1.id} AND `taggings`.`taggable_type` = 'User'",
          "UPDATE `users` SET `users`.`profile_id` = 33333 WHERE `users`.`id` = #{user2.id}",
          "SELECT `taggings`.* FROM `taggings` WHERE `taggings`.`taggable_id` = #{user2.id} AND `taggings`.`taggable_type` = 'User'",
        ]
      }) do
        user2 = User.find_by(name: 'Doggy')

        user1.profile_id = 12345
        user2.profile_id = 33333
        user1.save!
        user2.save!
      end
    end
  end
end
