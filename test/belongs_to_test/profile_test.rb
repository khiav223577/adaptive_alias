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
      Article.connection.rename_column :users, :profile_id, :profile_id_new

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.* FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal 'B1234', user.profile.id_number
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :users, :profile_id_new, :profile_id
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
      Article.connection.rename_column :users, :profile_id, :profile_id_new

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal 'B1234', user.association(:profile).send(:association_scope).pick(:id_number)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :users, :profile_id_new, :profile_id
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
      Article.connection.rename_column :users, :profile_id, :profile_id_new

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{profile_id} LIMIT 1",
      ]) do
        assert_equal ['B1234'], user.association(:profile).send(:association_scope).pluck(:id_number)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :users, :profile_id_new, :profile_id
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
      Article.connection.rename_column :users, :profile_id, :profile_id_new

      user = User.find_by(name: 'Catty')
      profile = user.profile

      assert_queries([
        "DELETE FROM `profiles` WHERE `profiles`.`id` = #{profile.id}",
      ]) do
        profile.destroy!
      end

      user.create_profile(profile.as_json)

      # --------- rollback rename migration ---------
      Article.connection.rename_column :users, :profile_id_new, :profile_id
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

  def test_join
    assert_queries([
      "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' LIMIT 1",
    ]) do
      assert_equal 'B1234', User.joins(:profile).where(name: 'Catty').pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', User.joins(:profile).where(name: 'Catty').pick(:id_number)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id_new` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `id_number` FROM `users` INNER JOIN `profiles` ON `profiles`.`id` = `users`.`profile_id` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', User.joins(:profile).where(name: 'Catty').pick(:id_number)
      end
    end
  end

  def test_reverse_join
    assert_queries([
      "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
    ]) do
      assert_equal 'B1234', Profile.joins(:user).merge(User.where(name: 'Catty')).pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', Profile.joins(:user).merge(User.where(name: 'Catty')).pick(:id_number)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id_new` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
        "SELECT `profiles`.`id_number` FROM `profiles` INNER JOIN `users` ON `users`.`profile_id` = `profiles`.`id` WHERE `users`.`name` = 'Catty' LIMIT 1",
      ]) do
        assert_equal 'B1234', Profile.joins(:user).merge(User.where(name: 'Catty')).pick(:id_number)
      end
    end
  end
end
