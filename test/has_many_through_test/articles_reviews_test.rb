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
end