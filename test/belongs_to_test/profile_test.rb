require 'test_helper'

class ProfileTest < Minitest::Test
  def setup
  end

  def teardown
    # make suer to rollback db schema even if some test cases fail
    Article.connection.rename_column :users, :profile_id_new, :profile_id rescue nil
  end

  def test_access
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `profiles`.* FROM `profiles` WHERE `profiles`.`id` = #{user.id} LIMIT 1"
    ]) do
      assert_equal 'B1234', user.profile.id_number
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :users, :profile_id, :profile_id_new

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.* FROM `profiles` WHERE `profiles`.`id` = #{user.id} LIMIT 1",
      ]) do
        assert_equal 'B1234', user.profile.id_number
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :users, :profile_id_new, :profile_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.* FROM `profiles` WHERE `profiles`.`id` = #{user.id} LIMIT 1",
      ]) do
        assert_equal 'B1234', user.profile.id_number
      end
    end
  end

  def test_association_scope
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{user.id} LIMIT 1"
    ]) do
      assert_equal 'B1234', user.association(:profile).send(:association_scope).pick(:id_number)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :users, :profile_id, :profile_id_new

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{user.id} LIMIT 1",
      ]) do
        assert_equal 'B1234', user.association(:profile).send(:association_scope).pick(:id_number)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :users, :profile_id_new, :profile_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `profiles`.`id_number` FROM `profiles` WHERE `profiles`.`id` = #{user.id} LIMIT 1",
      ]) do
        assert_equal 'B1234', user.association(:profile).send(:association_scope).pick(:id_number)
      end
    end
  end
end
