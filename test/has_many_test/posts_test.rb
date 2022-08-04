require 'test_helper'

class PostsTest < Minitest::Test
  def setup
  end

  def teardown
    # make suer to rollback db schema even if some test cases fail
    Post.connection.rename_column :posts, :user_id, :user_id_old
  rescue
    nil
  end

  def test_first
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Post B1', user.posts.first.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post B1', user.posts.first.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post B1', user.posts.first.title
      end
    end
  end

  def test_last
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'Post B3', user.posts.last.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post B3', user.posts.last.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post B3', user.posts.last.title
      end
    end
  end

  def test_to_a
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
    ]) do
      assert_equal ['Post B1', 'Post B2', 'Post B3'], user.posts.map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post B1', 'Post B2', 'Post B3'], user.posts.map(&:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
      ]) do
        assert_equal ['Post B1', 'Post B2', 'Post B3'], user.posts.map(&:title)
      end
    end
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
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`active` = TRUE AND `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post B2'], user.active_posts.map(&:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`active` = TRUE AND `posts`.`user_id_old` = #{user.id}",
      ]) do
        assert_equal ['Post B2'], user.active_posts.map(&:title)
      end
    end
  end

  def test_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
    ]) do
      assert_equal ['Post B1', 'Post B2', 'Post B3'], user.posts.pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post B1', 'Post B2', 'Post B3'], user.posts.pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
      ]) do
        assert_equal ['Post B1', 'Post B2', 'Post B3'], user.posts.pluck(:title)
      end
    end
  end

  def test_where_and_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['Post B2'], user.posts.where(active: true).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`active` = TRUE AND `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post B2'], user.posts.where(active: true).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`active` = TRUE AND `posts`.`user_id_old` = #{user.id}",
      ]) do
        assert_equal ['Post B2'], user.posts.where(active: true).pluck(:title)
      end
    end
  end

  def test_create
    user = User.find_by(name: 'Catty')
    post = nil

    assert_queries([
      "INSERT INTO `posts` (`user_id_old`, `title`) VALUES (2, 'new post')",
    ]) do
      post = user.posts.create!(title: 'new post')
    end

    post.destroy
    post = nil

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "INSERT INTO `posts` (`user_id_old`, `title`) VALUES (2, 'new post')",
        'ROLLBACK',
        "INSERT INTO `posts` (`user_id`, `title`) VALUES (2, 'new post')",
      ]) do
        post = user.posts.create!(title: 'new post')
      end

      post.destroy
      post = nil

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "INSERT INTO `posts` (`user_id`, `title`) VALUES (2, 'new post')",
        'ROLLBACK',
        "INSERT INTO `posts` (`user_id_old`, `title`) VALUES (2, 'new post')",
      ]) do
        post = user.posts.create!(title: 'new post')
      end

      post.destroy
      post = nil
    end
  ensure
    post.destroy if post
  end

  def test_destroy
    user = User.find_by(name: 'Catty')
    posts = Array.new(7){ user.posts.create!(title: 'new post') }

    assert_queries([
      "DELETE FROM `posts` WHERE `posts`.`id` = #{posts.last.id}",
    ]) do
      posts.pop.destroy!
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "DELETE FROM `posts` WHERE `posts`.`id` = #{posts.last.id}",
      ]) do
        posts.pop.destroy!
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "DELETE FROM `posts` WHERE `posts`.`id` = #{posts.last.id}",
      ]) do
        posts.pop.destroy!
      end
    end
  ensure
    posts.each(&:destroy!)
    posts.clear
  end
end
