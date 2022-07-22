require 'test_helper'

class HasManyAssociationTest < Minitest::Test
  def setup
  end

  def teardown
    # make suer to rollback db schema even if some test cases fail
    Post.connection.rename_column :posts, :user_id, :user_id_old rescue nil
  end

  def test_to_a_with_default_scope
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['Post B2'], user.active_posts.map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post B2'], user.active_posts.map(&:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post B2'], user.active_posts.map(&:title)
      end
    end
  end
end
