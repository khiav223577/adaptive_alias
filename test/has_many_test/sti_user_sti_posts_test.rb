require 'test_helper'

class StiUserStiPostsTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(Post, :user_id_old, :user_id)
  end

  def test_first
    user = Users::AgentUser.find_by(name: 'Hachu')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Post D1', user.agent_posts.first.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post D1', user.agent_posts.first.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post D1', user.agent_posts.first.title
      end
    end
  end

  def test_last
    user = Users::AgentUser.find_by(name: 'Hachu')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'Post D3', user.agent_posts.last.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post D3', user.agent_posts.last.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post D3', user.agent_posts.last.title
      end
    end
  end

  def test_same_model_last
    user = Users::AgentUser.find_by(name: 'Hachu')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'Post D3', user.agent_posts.last.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post D3', user.agent_posts.last.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} ORDER BY `posts`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Post D3', user.agent_posts.last.title
      end
    end
  end

  def test_to_a
    user = Users::AgentUser.find_by(name: 'Hachu')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id}",
    ]) do
      assert_equal ['Post D1', 'Post D2', 'Post D3'], user.agent_posts.map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id}",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], user.agent_posts.map(&:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id}",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id}",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], user.agent_posts.map(&:title)
      end
    end
  end

  def test_to_a_with_default_scope
    user = Users::AgentUser.find_by(name: 'Hachu')
    assert_queries([
      "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['Post D2'], user.active_agent_posts.map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post D2'], user.active_agent_posts.map(&:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.* FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post D2'], user.active_agent_posts.map(&:title)
      end
    end
  end

  def test_pluck
    user = Users::AgentUser.find_by(name: 'Hachu')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id}",
    ]) do
      assert_equal ['Post D1', 'Post D2', 'Post D3'], user.agent_posts.pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], user.agent_posts.pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id}",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], user.agent_posts.pluck(:title)
      end
    end
  end

  def test_same_model_pluck
    user = Users::AgentUser.find_by(name: 'Hachu')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id}",
    ]) do
      assert_equal ['Post D1', 'Post D2', 'Post D3'], user.agent_posts.pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], user.agent_posts.pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id}",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id}",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], user.agent_posts.pluck(:title)
      end
    end
  end

  def test_where_and_pluck
    user = Users::AgentUser.find_by(name: 'Hachu')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['Post D2'], user.agent_posts.where(active: true).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post D2'], user.agent_posts.where(active: true).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post D2'], user.agent_posts.where(active: true).pluck(:title)
      end
    end
  end

  def test_same_model_where_and_pluck
    user = Users::AgentUser.find_by(name: 'Hachu')
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['Post D2'], user.agent_posts.where(active: true).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post D2'], user.agent_posts.where(active: true).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id` = #{user.id} AND `posts`.`active` = TRUE",
        "SELECT `posts`.`title` FROM `posts` WHERE `posts`.`type` = 'Posts::AgentPost' AND `posts`.`user_id_old` = #{user.id} AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['Post D2'], user.agent_posts.where(active: true).pluck(:title)
      end
    end
  end

  def test_create
    user = Users::AgentUser.find_by(name: 'Hachu')
    post = nil

    assert_queries([
      "INSERT INTO `posts` (`type`, `user_id_old`, `title`) VALUES ('Posts::AgentPost', 4, 'new post')",
    ]) do
      post = user.agent_posts.create!(title: 'new post')
    end

    post.destroy
    post = nil

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "INSERT INTO `posts` (`type`, `user_id_old`, `title`) VALUES ('Posts::AgentPost', 4, 'new post')",
        "INSERT INTO `posts` (`type`, `title`, `user_id`) VALUES ('Posts::AgentPost', 'new post', 4)",
      ]) do
        post = user.agent_posts.create!(title: 'new post')
      end

      post.destroy
      post = nil

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = Users::AgentUser.find_by(name: 'Hachu')
      assert_queries([
        "INSERT INTO `posts` (`type`, `user_id`, `title`) VALUES ('Posts::AgentPost', 4, 'new post')",
        "INSERT INTO `posts` (`type`, `title`, `user_id_old`) VALUES ('Posts::AgentPost', 'new post', 4)",
      ]) do
        post = user.agent_posts.create!(title: 'new post')
      end

      post.destroy
      post = nil
    end
  ensure
    post.destroy if post
  end

  def test_destroy
    user = Users::AgentUser.find_by(name: 'Hachu')
    posts = Array.new(7){ user.agent_posts.create!(title: 'new post') }

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
      "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
    ]) do
      assert_equal ['Post D1', 'Post D2', 'Post D3'], Users::AgentUser.joins(:posts).where(name: 'Hachu').pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], Users::AgentUser.joins(:posts).where(name: 'Hachu').pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
        "SELECT `title` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], Users::AgentUser.joins(:posts).where(name: 'Hachu').pluck(:title)
      end
    end
  end

  def test_pluck_with_left_join
    assert_queries([
      "SELECT `title` FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
    ]) do
      assert_equal ['Post D1', 'Post D2', 'Post D3'], Users::AgentUser.left_joins(:posts).where(name: 'Hachu').pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `title` FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
        "SELECT `title` FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], Users::AgentUser.left_joins(:posts).where(name: 'Hachu').pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `title` FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
        "SELECT `title` FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], Users::AgentUser.left_joins(:posts).where(name: 'Hachu').pluck(:title)
      end
    end
  end

  def test_first_with_join
    assert_queries([
      "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Hachu', Users::AgentUser.joins(:posts).where(name: 'Hachu').first.name
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Hachu', Users::AgentUser.joins(:posts).where(name: 'Hachu').first.name
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Hachu', Users::AgentUser.joins(:posts).where(name: 'Hachu').first.name
      end
    end
  end

  def test_first_with_left_join
    assert_queries([
      "SELECT `users`.* FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Hachu', Users::AgentUser.left_joins(:posts).where(name: 'Hachu').first.name
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Hachu', Users::AgentUser.left_joins(:posts).where(name: 'Hachu').first.name
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Hachu', Users::AgentUser.left_joins(:posts).where(name: 'Hachu').first.name
      end
    end
  end

  def test_pluck_with_join_reversely
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
    ]) do
      assert_equal ['Post D1', 'Post D2', 'Post D3'], Post.joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], Post.joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
        "SELECT `posts`.`title` FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], Post.joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).pluck(:title)
      end
    end
  end

  def test_pluck_with_left_join_reversely
    assert_queries([
      "SELECT `posts`.`title` FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
    ]) do
      assert_equal ['Post D1', 'Post D2', 'Post D3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
        "SELECT `posts`.`title` FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.`title` FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
        "SELECT `posts`.`title` FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).pluck(:title)
      end
    end
  end

  def test_first_with_join_reversely
    assert_queries([
      "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `posts`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Post D1', Post.joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).first.title
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post D1', Post.joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).first.title
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `posts`.`id` ASC LIMIT 1",
        "SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu' ORDER BY `posts`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Post D1', Post.joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).first.title
      end
    end
  end

  def test_to_a_with_left_join_reversely
    assert_queries([
      "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
    ]) do
      assert_equal ['Post D1', 'Post D2', 'Post D3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
        "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).map(&:title)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
        "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`type` = 'Users::AgentUser' AND `users`.`name` = 'Hachu'",
      ]) do
        assert_equal ['Post D1', 'Post D2', 'Post D3'], Post.left_joins(:user).merge(Users::AgentUser.where(name: 'Hachu')).map(&:title)
      end
    end
  end
end
