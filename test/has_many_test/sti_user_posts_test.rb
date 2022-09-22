require 'test_helper'

class StiUserPostsTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(Post, :user_id_old, :user_id)
  end

  def test_first
    user = Users::AgentUser.find_by(name: 'Pepper')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Post C1', user.posts.first.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post C1', user.posts.first.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post C1', user.posts.first.title
      end
    end
  end

  def test_last
    user = Users::AgentUser.find_by(name: 'Pepper')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'Post C3', user.posts.last.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post C3', user.posts.last.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post C3', user.posts.last.title
      end
    end
  end

  def test_same_model_last
    user = Users::AgentUser.find_by(name: 'Pepper')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'Post C3', user.posts.last.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post C3', user.posts.last.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post C3', user.posts.last.title
      end
    end
  end

  def test_to_a
    user = Users::AgentUser.find_by(name: 'Pepper')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
    ]) do
      assert_equal ['Post C1', 'Post C2', 'Post C3'], user.posts.map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], user.posts.map(&:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], user.posts.map(&:title)
      end
    end
  end

  def test_to_a_with_default_scope
    user = Users::AgentUser.find_by(name: 'Pepper')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['Post C2'], user.active_posts.map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post C2'], user.active_posts.map(&:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post C2'], user.active_posts.map(&:title)
      end
    end
  end

  def test_pluck
    user = Users::AgentUser.find_by(name: 'Pepper')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
    ]) do
      assert_equal ['Post C1', 'Post C2', 'Post C3'], user.posts.pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], user.posts.pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], user.posts.pluck(:title)
      end
    end
  end

  def test_same_model_pluck
    user = Users::AgentUser.find_by(name: 'Pepper')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
    ]) do
      assert_equal ['Post C1', 'Post C2', 'Post C3'], user.posts.pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], user.posts.pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id}",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], user.posts.pluck(:title)
      end
    end
  end

  def test_where_and_pluck
    user = Users::AgentUser.find_by(name: 'Pepper')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['Post C2'], user.posts.where(active: true).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post C2'], user.posts.where(active: true).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post C2'], user.posts.where(active: true).pluck(:title)
      end
    end
  end

  def test_same_model_where_and_pluck
    user = Users::AgentUser.find_by(name: 'Pepper')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['Post C2'], user.posts.where(active: true).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post C2'], user.posts.where(active: true).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post C2'], user.posts.where(active: true).pluck(:title)
      end
    end
  end

  def test_create
    user = Users::AgentUser.find_by(name: 'Pepper')
    post = nil

    assert_queries([
      "INSERT INTO `posts` (`user_id_old`, `title`) VALUES (3, 'new post')",
    ]) do
      post = user.posts.create!(title: 'new post')
    end

    post.destroy
    post = nil

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "INSERT INTO `posts` (`user_id_old`, `title`) VALUES (3, 'new post')",
        'ROLLBACK',
        "INSERT INTO `posts` (`user_id`, `title`) VALUES (3, 'new post')",
      ]) do
        post = user.posts.create!(title: 'new post')
      end

      post.destroy
      post = nil

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Pepper')
      assert_queries([
        "INSERT INTO `posts` (`user_id`, `title`) VALUES (3, 'new post')",
        'ROLLBACK',
        "INSERT INTO `posts` (`user_id_old`, `title`) VALUES (3, 'new post')",
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
    user = Users::AgentUser.find_by(name: 'Pepper')
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
      "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
    ]) do
      assert_equal ['Post C1', 'Post C2', 'Post C3'], Users::AgentUser.joins(:posts).where(name: 'Pepper').pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], Users::AgentUser.joins(:posts).where(name: 'Pepper').pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], Users::AgentUser.joins(:posts).where(name: 'Pepper').pluck(:title)
      end
    end
  end

  def test_pluck_with_left_join
    assert_queries([
      "SELECT `title` FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
    ]) do
      assert_equal ['Post C1', 'Post C2', 'Post C3'], Users::AgentUser.left_joins(:posts).where(name: 'Pepper').pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `title` FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
        "SELECT `title` FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], Users::AgentUser.left_joins(:posts).where(name: 'Pepper').pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `title` FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
        "SELECT `title` FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], Users::AgentUser.left_joins(:posts).where(name: 'Pepper').pluck(:title)
      end
    end
  end

  def test_first_with_join
    assert_queries([
      "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Pepper', Users::AgentUser.joins(:posts).where(name: 'Pepper').first.name
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Pepper', Users::AgentUser.joins(:posts).where(name: 'Pepper').first.name
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Pepper', Users::AgentUser.joins(:posts).where(name: 'Pepper').first.name
      end
    end
  end

  def test_first_with_left_join
    assert_queries([
      "SELECT `users`.* FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Pepper', Users::AgentUser.left_joins(:posts).where(name: 'Pepper').first.name
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Pepper', Users::AgentUser.left_joins(:posts).where(name: 'Pepper').first.name
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Pepper', Users::AgentUser.left_joins(:posts).where(name: 'Pepper').first.name
      end
    end
  end

  def test_pluck_with_join_reversely
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
    ]) do
      assert_equal ['Post C1', 'Post C2', 'Post C3'], Post.joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], Post.joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], Post.joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).pluck(:title)
      end
    end
  end

  def test_pluck_with_left_join_reversely
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
    ]) do
      assert_equal ['Post C1', 'Post C2', 'Post C3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
        "SELECT `posts`.`title` FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
        "SELECT `posts`.`title` FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).pluck(:title)
      end
    end
  end

  def test_first_with_join_reversely
    assert_queries([
      "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `posts`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Post C1', Post.joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).first.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post C1', Post.joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).first.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper' ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post C1', Post.joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).first.title
      end
    end
  end

  def test_to_a_with_left_join_reversely
    assert_queries([
      "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
    ]) do
      assert_equal ['Post C1', 'Post C2', 'Post C3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
        "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).map(&:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
        "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Pepper'",
      ]) do
        assert_equal ['Post C1', 'Post C2', 'Post C3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Pepper')).map(&:title)
      end
    end
  end
end
