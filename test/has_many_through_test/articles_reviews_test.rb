require 'test_helper'

class ArticlesReviewsTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(Article, :user_id, :user_id_abc)
  end

  def test_first
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' ORDER BY `reviews`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'article review B1', user.articles_reviews.first.content
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' ORDER BY `reviews`.`id` ASC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' ORDER BY `reviews`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'article review B1', user.articles_reviews.first.content
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' ORDER BY `reviews`.`id` ASC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' ORDER BY `reviews`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'article review B1', user.articles_reviews.first.content
      end
    end
  end

  def test_last
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' ORDER BY `reviews`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'article review C1', user.articles_reviews.last.content
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' ORDER BY `reviews`.`id` DESC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' ORDER BY `reviews`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'article review C1', user.articles_reviews.last.content
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' ORDER BY `reviews`.`id` DESC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' ORDER BY `reviews`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'article review C1', user.articles_reviews.last.content
      end
    end
  end

  def test_to_a
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article'",
    ]) do
      assert_equal ['article review B1', 'article review B2', 'article review C1'], user.articles_reviews.map(&:content)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article'",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article'",
      ]) do
        assert_equal ['article review B1', 'article review B2', 'article review C1'], user.articles_reviews.map(&:content)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article'",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article'",
      ]) do
        assert_equal ['article review B1', 'article review B2', 'article review C1'], user.articles_reviews.map(&:content)
      end
    end
  end

  def test_to_a_with_default_scope
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' AND `articles`.`active` = TRUE",
    ]) do
      assert_equal ['article review C1'], user.active_articles_reviews.map(&:content)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' AND `articles`.`active` = TRUE",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' AND `articles`.`active` = TRUE",
      ]) do
        assert_equal ['article review C1'], user.active_articles_reviews.map(&:content)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' AND `articles`.`active` = TRUE",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' AND `articles`.`active` = TRUE",
      ]) do
        assert_equal ['article review C1'], user.active_articles_reviews.map(&:content)
      end
    end
  end

  def test_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article'",
    ]) do
      assert_equal ['article review B1', 'article review B2', 'article review C1'], user.articles_reviews.pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article'",
      ]) do
        assert_equal ['article review B1', 'article review B2', 'article review C1'], user.articles_reviews.pluck(:content)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article'",
      ]) do
        assert_equal ['article review B1', 'article review B2', 'article review C1'], user.articles_reviews.pluck(:content)
      end
    end
  end

  def test_where_and_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' AND `articles`.`active` = TRUE",
    ]) do
      assert_equal ['article review C1'], user.articles_reviews.merge(Article.where(active: true)).pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' AND `articles`.`active` = TRUE",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' AND `articles`.`active` = TRUE",
      ]) do
        assert_equal ['article review C1'], user.articles_reviews.merge(Article.where(active: true)).pluck(:content)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id_abc` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' AND `articles`.`active` = TRUE",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `reviews`.`reviewable_id` = `articles`.`id` WHERE `articles`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Article' AND `articles`.`active` = TRUE",
      ]) do
        assert_equal ['article review C1'], user.articles_reviews.merge(Article.where(active: true)).pluck(:content)
      end
    end
  end

  def test_pluck_with_join
    assert_queries([
      "SELECT `content` FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Article' AND `reviews`.`reviewable_id` = `articles`.`id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['article review B1', 'article review B2', 'article review C1'], User.joins(articles: :reviews).where(name: 'Catty').pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `content` FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Article' AND `reviews`.`reviewable_id` = `articles`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `content` FROM `users` INNER JOIN `articles` ON `articles`.`user_id_abc` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Article' AND `reviews`.`reviewable_id` = `articles`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['article review B1', 'article review B2', 'article review C1'], User.joins(articles: :reviews).where(name: 'Catty').pluck(:content)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `content` FROM `users` INNER JOIN `articles` ON `articles`.`user_id_abc` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Article' AND `reviews`.`reviewable_id` = `articles`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `content` FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Article' AND `reviews`.`reviewable_id` = `articles`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['article review B1', 'article review B2', 'article review C1'], User.joins(articles: :reviews).where(name: 'Catty').pluck(:content)
      end
    end
  end

  def test_pluck_with_join_reversely
    assert_queries([
      "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `articles`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Article') INNER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['article review B1', 'article review B2', 'article review C1'], Review.joins(article: :user).merge(User.where(name: 'Catty')).pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `articles`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Article') INNER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `articles`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Article') INNER JOIN `users` ON `users`.`id` = `articles`.`user_id_abc` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['article review B1', 'article review B2', 'article review C1'], Review.joins(article: :user).merge(User.where(name: 'Catty')).pluck(:content)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `articles`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Article') INNER JOIN `users` ON `users`.`id` = `articles`.`user_id_abc` WHERE `users`.`name` = 'Catty'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `articles` ON `articles`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Article') INNER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['article review B1', 'article review B2', 'article review C1'], Review.joins(article: :user).merge(User.where(name: 'Catty')).pluck(:content)
      end
    end
  end
end
