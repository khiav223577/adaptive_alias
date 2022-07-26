require 'test_helper'

class ArticlesTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(Article, :user_id, :user_id_abc)
  end

  def test_first
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Article B1', user.articles.first.title
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` ASC LIMIT 1",
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} ORDER BY `articles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Article B1', user.articles.first.title
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} ORDER BY `articles`.`id` ASC LIMIT 1",
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Article B1', user.articles.first.title
      end
    end
  end

  def test_last
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'Article B3', user.articles.last.title
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1",
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Article B3', user.articles.last.title
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1",
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Article B3', user.articles.last.title
      end
    end
  end

  def test_same_model_last
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'Article B3', user.articles.last.title
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1",
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Article B3', user.articles.last.title
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1",
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Article B3', user.articles.last.title
      end
    end
  end

  def test_to_a
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id}",
    ]) do
      assert_equal ['Article B1', 'Article B2', 'Article B3'], user.articles.map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id}",
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id}",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], user.articles.map(&:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id}",
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], user.articles.map(&:title)
      end
    end
  end

  def test_to_a_with_default_scope
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} AND `articles`.`active` = TRUE",
    ]) do
      assert_equal ['Article B2'], user.active_articles.map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} AND `articles`.`active` = TRUE",
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} AND `articles`.`active` = TRUE",
      ]) do
        assert_equal ['Article B2'], user.active_articles.map(&:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} AND `articles`.`active` = TRUE",
        "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} AND `articles`.`active` = TRUE",
      ]) do
        assert_equal ['Article B2'], user.active_articles.map(&:title)
      end
    end
  end

  def test_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id}",
    ]) do
      assert_equal ['Article B1', 'Article B2', 'Article B3'], user.articles.pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id}",
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id}",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], user.articles.pluck(:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id}",
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], user.articles.pluck(:title)
      end
    end
  end

  def test_same_model_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id}",
    ]) do
      assert_equal ['Article B1', 'Article B2', 'Article B3'], user.articles.pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id}",
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id}",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], user.articles.pluck(:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id}",
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], user.articles.pluck(:title)
      end
    end
  end

  def test_where_and_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id} AND `articles`.`active` = TRUE",
    ]) do
      assert_equal ['Article B2'], user.articles.where(active: true).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id} AND `articles`.`active` = TRUE",
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} AND `articles`.`active` = TRUE",
      ]) do
        assert_equal ['Article B2'], user.articles.where(active: true).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} AND `articles`.`active` = TRUE",
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id} AND `articles`.`active` = TRUE",
      ]) do
        assert_equal ['Article B2'], user.articles.where(active: true).pluck(:title)
      end
    end
  end

  def test_same_model_where_and_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id} AND `articles`.`active` = TRUE",
    ]) do
      assert_equal ['Article B2'], user.articles.where(active: true).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id} AND `articles`.`active` = TRUE",
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} AND `articles`.`active` = TRUE",
      ]) do
        assert_equal ['Article B2'], user.articles.where(active: true).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id_abc` = #{user.id} AND `articles`.`active` = TRUE",
        "SELECT `articles`.`title` FROM `articles` WHERE `articles`.`user_id` = #{user.id} AND `articles`.`active` = TRUE",
      ]) do
        assert_equal ['Article B2'], user.articles.where(active: true).pluck(:title)
      end
    end
  end

  def test_create
    user = User.find_by(name: 'Catty')
    article = nil

    assert_queries([
      "INSERT INTO `articles` (`user_id`, `title`) VALUES (2, 'new article')",
    ]) do
      article = user.articles.create!(title: 'new article')
    end

    article.destroy
    article = nil

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      user = User.find_by(name: 'Catty')
      assert_queries([
        "INSERT INTO `articles` (`user_id`, `title`) VALUES (2, 'new article')",
        "INSERT INTO `articles` (`user_id_abc`, `title`) VALUES (2, 'new article')",
      ]) do
        article = user.articles.create!(title: 'new article')
      end

      article.destroy
      article = nil

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "INSERT INTO `articles` (`user_id_abc`, `title`) VALUES (2, 'new article')",
        "INSERT INTO `articles` (`user_id`, `title`) VALUES (2, 'new article')",
      ]) do
        article = user.articles.create!(title: 'new article')
      end

      article.destroy
      article = nil
    end
  ensure
    article.destroy if article
  end

  def test_destroy
    user = User.find_by(name: 'Catty')
    articles = Array.new(7){ user.articles.create!(title: 'new article') }

    assert_queries([
      "DELETE FROM `articles` WHERE `articles`.`id` = #{articles.last.id}",
    ]) do
      articles.pop.destroy!
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "DELETE FROM `articles` WHERE `articles`.`id` = #{articles.last.id}",
      ]) do
        articles.pop.destroy!
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "DELETE FROM `articles` WHERE `articles`.`id` = #{articles.last.id}",
      ]) do
        articles.pop.destroy!
      end
    end
  ensure
    articles.each(&:destroy!)
    articles.clear
  end

  def test_pluck_with_join
    assert_queries([
      "SELECT `title` FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['Article B1', 'Article B2', 'Article B3'], User.joins(:articles).where(name: 'Catty').pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `title` FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `title` FROM `users` INNER JOIN `articles` ON `articles`.`user_id_abc` = `users`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], User.joins(:articles).where(name: 'Catty').pluck(:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `title` FROM `users` INNER JOIN `articles` ON `articles`.`user_id_abc` = `users`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `title` FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], User.joins(:articles).where(name: 'Catty').pluck(:title)
      end
    end
  end

  def test_pluck_with_left_join
    assert_queries([
      "SELECT `title` FROM `users` LEFT OUTER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['Article B1', 'Article B2', 'Article B3'], User.left_joins(:articles).where(name: 'Catty').pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `title` FROM `users` LEFT OUTER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `title` FROM `users` LEFT OUTER JOIN `articles` ON `articles`.`user_id_abc` = `users`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], User.left_joins(:articles).where(name: 'Catty').pluck(:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `title` FROM `users` LEFT OUTER JOIN `articles` ON `articles`.`user_id_abc` = `users`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `title` FROM `users` LEFT OUTER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], User.left_joins(:articles).where(name: 'Catty').pluck(:title)
      end
    end
  end

  def test_first_with_join
    assert_queries([
      "SELECT `users`.* FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Catty', User.joins(:articles).where(name: 'Catty').first.name
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `articles` ON `articles`.`user_id_abc` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Catty', User.joins(:articles).where(name: 'Catty').first.name
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `users`.* FROM `users` INNER JOIN `articles` ON `articles`.`user_id_abc` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Catty', User.joins(:articles).where(name: 'Catty').first.name
      end
    end
  end

  def test_first_with_left_join
    assert_queries([
      "SELECT `users`.* FROM `users` LEFT OUTER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Catty', User.left_joins(:articles).where(name: 'Catty').first.name
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `articles` ON `articles`.`user_id_abc` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Catty', User.left_joins(:articles).where(name: 'Catty').first.name
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `articles` ON `articles`.`user_id_abc` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
        "SELECT `users`.* FROM `users` LEFT OUTER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`name` = 'Catty' ORDER BY `users`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Catty', User.left_joins(:articles).where(name: 'Catty').first.name
      end
    end
  end

  def test_pluck_with_join_reversely
    assert_queries([
      "SELECT `articles`.`title` FROM `articles` INNER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['Article B1', 'Article B2', 'Article B3'], Article.joins(:user).merge(User.where(name: 'Catty')).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` INNER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
        "SELECT `articles`.`title` FROM `articles` INNER JOIN `users` ON `users`.`id` = `articles`.`user_id_abc` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], Article.joins(:user).merge(User.where(name: 'Catty')).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` INNER JOIN `users` ON `users`.`id` = `articles`.`user_id_abc` WHERE `users`.`name` = 'Catty'",
        "SELECT `articles`.`title` FROM `articles` INNER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], Article.joins(:user).merge(User.where(name: 'Catty')).pluck(:title)
      end
    end
  end

  def test_pluck_with_left_join_reversely
    assert_queries([
      "SELECT `articles`.`title` FROM `articles` LEFT OUTER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['Article B1', 'Article B2', 'Article B3'], Article.left_joins(:user).merge(User.where(name: 'Catty')).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` LEFT OUTER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
        "SELECT `articles`.`title` FROM `articles` LEFT OUTER JOIN `users` ON `users`.`id` = `articles`.`user_id_abc` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], Article.left_joins(:user).merge(User.where(name: 'Catty')).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `articles`.`title` FROM `articles` LEFT OUTER JOIN `users` ON `users`.`id` = `articles`.`user_id_abc` WHERE `users`.`name` = 'Catty'",
        "SELECT `articles`.`title` FROM `articles` LEFT OUTER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], Article.left_joins(:user).merge(User.where(name: 'Catty')).pluck(:title)
      end
    end
  end

  def test_first_with_join_reversely
    assert_queries([
      "SELECT `articles`.* FROM `articles` INNER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty' ORDER BY `articles`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Article B1', Article.joins(:user).merge(User.where(name: 'Catty')).first.title
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `articles`.* FROM `articles` INNER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty' ORDER BY `articles`.`id` ASC LIMIT 1",
        "SELECT `articles`.* FROM `articles` INNER JOIN `users` ON `users`.`id` = `articles`.`user_id_abc` WHERE `users`.`name` = 'Catty' ORDER BY `articles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Article B1', Article.joins(:user).merge(User.where(name: 'Catty')).first.title
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `articles`.* FROM `articles` INNER JOIN `users` ON `users`.`id` = `articles`.`user_id_abc` WHERE `users`.`name` = 'Catty' ORDER BY `articles`.`id` ASC LIMIT 1",
        "SELECT `articles`.* FROM `articles` INNER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty' ORDER BY `articles`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Article B1', Article.joins(:user).merge(User.where(name: 'Catty')).first.title
      end
    end
  end

  def test_to_a_with_left_join_reversely
    assert_queries([
      "SELECT `articles`.* FROM `articles` LEFT OUTER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['Article B1', 'Article B2', 'Article B3'], Article.left_joins(:user).merge(User.where(name: 'Catty')).map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_queries([
        "SELECT `articles`.* FROM `articles` LEFT OUTER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
        "SELECT `articles`.* FROM `articles` LEFT OUTER JOIN `users` ON `users`.`id` = `articles`.`user_id_abc` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], Article.left_joins(:user).merge(User.where(name: 'Catty')).map(&:title)
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_queries([
        "SELECT `articles`.* FROM `articles` LEFT OUTER JOIN `users` ON `users`.`id` = `articles`.`user_id_abc` WHERE `users`.`name` = 'Catty'",
        "SELECT `articles`.* FROM `articles` LEFT OUTER JOIN `users` ON `users`.`id` = `articles`.`user_id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['Article B1', 'Article B2', 'Article B3'], Article.left_joins(:user).merge(User.where(name: 'Catty')).map(&:title)
      end
    end
  end
end
