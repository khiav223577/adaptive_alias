require 'test_helper'

class PostsTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(Post, :user_id_old, :user_id)
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

  def test_same_model_last
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'Post B3', user.posts.last.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post B3', user.posts.last.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
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

  def test_same_model_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
    ]) do
      assert_equal ['Post B1', 'Post B2', 'Post B3'], user.posts.pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post B1', 'Post B2', 'Post B3'], user.posts.pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
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
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post B2'], user.posts.where(active: true).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post B2'], user.posts.where(active: true).pluck(:title)
      end
    end
  end

  def test_same_model_where_and_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['Post B2'], user.posts.where(active: true).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post B2'], user.posts.where(active: true).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
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

  def test_pluck_with_join
    assert_queries([
      "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['Post B1', 'Post B2', 'Post B3'], User.joins(:posts).where(name: 'Catty').pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Post B1', 'Post B2', 'Post B3'], User.joins(:posts).where(name: 'Catty').pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Post B1', 'Post B2', 'Post B3'], User.joins(:posts).where(name: 'Catty').pluck(:title)
      end
    end
  end

  def test_first_with_join
    assert_queries([
      "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Catty', User.joins(:posts).where(name: 'Catty').first.name
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Catty', User.joins(:posts).where(name: 'Catty').first.name
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Catty', User.joins(:posts).where(name: 'Catty').first.name
      end
    end
  end

  def test_pluck_with_join_reversely
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['Post B1', 'Post B2', 'Post B3'], Post.joins(:user).merge(User.where(name: 'Catty')).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`name` = 'Catty'",
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Post B1', 'Post B2', 'Post B3'], Post.joins(:user).merge(User.where(name: 'Catty')).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`name` = 'Catty'",
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Post B1', 'Post B2', 'Post B3'], Post.joins(:user).merge(User.where(name: 'Catty')).pluck(:title)
      end
    end
  end

  def test_first_with_join_reversely
    assert_queries([
      "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`name` = 'Catty' ORDER BY `posts`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Post B1', Post.joins(:user).merge(User.where(name: 'Catty')).first.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`name` = 'Catty' ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`name` = 'Catty' ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post B1', Post.joins(:user).merge(User.where(name: 'Catty')).first.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`name` = 'Catty' ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`name` = 'Catty' ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post B1', Post.joins(:user).merge(User.where(name: 'Catty')).first.title
      end
    end
  end
end
