require 'test_helper'

class PostsReviewsTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(Post, :user_id_old, :user_id)
  end

  def test_first
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' ORDER BY `reviews`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'post review B1', user.posts_reviews.first.content
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' ORDER BY `reviews`.`id` ASC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' ORDER BY `reviews`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'post review B1', user.posts_reviews.first.content
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' ORDER BY `reviews`.`id` ASC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' ORDER BY `reviews`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'post review B1', user.posts_reviews.first.content
      end
    end
  end

  def test_last
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' ORDER BY `reviews`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'post review C1', user.posts_reviews.last.content
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' ORDER BY `reviews`.`id` DESC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' ORDER BY `reviews`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'post review C1', user.posts_reviews.last.content
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' ORDER BY `reviews`.`id` DESC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' ORDER BY `reviews`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'post review C1', user.posts_reviews.last.content
      end
    end
  end

  def test_to_a
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post'",
    ]) do
      assert_equal ['post review B1', 'post review B2', 'post review C1'], user.posts_reviews.map(&:content)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post'",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post'",
      ]) do
        assert_equal ['post review B1', 'post review B2', 'post review C1'], user.posts_reviews.map(&:content)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post'",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post'",
      ]) do
        assert_equal ['post review B1', 'post review B2', 'post review C1'], user.posts_reviews.map(&:content)
      end
    end
  end

  def test_to_a_with_default_scope
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['post review C1'], user.active_posts_reviews.map(&:content)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' AND `posts`.`active` = TRUE",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['post review C1'], user.active_posts_reviews.map(&:content)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' AND `posts`.`active` = TRUE",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['post review C1'], user.active_posts_reviews.map(&:content)
      end
    end
  end

  def test_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post'",
    ]) do
      assert_equal ['post review B1', 'post review B2', 'post review C1'], user.posts_reviews.pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post'",
      ]) do
        assert_equal ['post review B1', 'post review B2', 'post review C1'], user.posts_reviews.pluck(:content)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post'",
      ]) do
        assert_equal ['post review B1', 'post review B2', 'post review C1'], user.posts_reviews.pluck(:content)
      end
    end
  end

  def test_where_and_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' AND `posts`.`active` = TRUE",
    ]) do
      assert_equal ['post review C1'], user.posts_reviews.merge(Post.where(active: true)).pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' AND `posts`.`active` = TRUE",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['post review C1'], user.posts_reviews.merge(Post.where(active: true)).pluck(:content)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' AND `posts`.`active` = TRUE",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `reviews`.`reviewable_id` = `posts`.`id` WHERE `posts`.`user_id_old` = #{user.id} AND `reviews`.`reviewable_type` = 'Post' AND `posts`.`active` = TRUE",
      ]) do
        assert_equal ['post review C1'], user.posts_reviews.merge(Post.where(active: true)).pluck(:content)
      end
    end
  end

  def test_join
    assert_queries([
      "SELECT `content` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Post' AND `reviews`.`reviewable_id` = `posts`.`id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['post review B1', 'post review B2', 'post review C1'], User.joins(posts: :reviews).where(name: 'Catty').pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `content` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Post' AND `reviews`.`reviewable_id` = `posts`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `content` FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Post' AND `reviews`.`reviewable_id` = `posts`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['post review B1', 'post review B2', 'post review C1'], User.joins(posts: :reviews).where(name: 'Catty').pluck(:content)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `content` FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Post' AND `reviews`.`reviewable_id` = `posts`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `content` FROM `users` INNER JOIN `posts` ON `posts`.`user_id_old` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Post' AND `reviews`.`reviewable_id` = `posts`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['post review B1', 'post review B2', 'post review C1'], User.joins(posts: :reviews).where(name: 'Catty').pluck(:content)
      end
    end
  end

  def test_reverse_join
    assert_queries([
      "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `posts`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Post') INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['post review B1', 'post review B2', 'post review C1'], Review.joins(post: :user).merge(User.where(name: 'Catty')).pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Post.connection.rename_column :posts, :user_id_old, :user_id
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `posts`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Post') INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`name` = 'Catty'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `posts`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Post') INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['post review B1', 'post review B2', 'post review C1'], Review.joins(post: :user).merge(User.where(name: 'Catty')).pluck(:content)
      end

      # --------- rollback rename migration ---------
      Post.connection.rename_column :posts, :user_id, :user_id_old
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `posts`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Post') INNER JOIN `users` ON `users`.`id` = `posts`.`user_id` WHERE `users`.`name` = 'Catty'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `posts` ON `posts`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Post') INNER JOIN `users` ON `users`.`id` = `posts`.`user_id_old` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['post review B1', 'post review B2', 'post review C1'], Review.joins(post: :user).merge(User.where(name: 'Catty')).pluck(:content)
      end
    end
  end
end
