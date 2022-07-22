require 'test_helper'

class ArticlesTest < Minitest::Test
  def setup
  end

  def teardown
    # make suer to rollback db schema even if some test cases fail
    Article.connection.rename_column :articles, :user_id_abc, :user_id rescue nil
  end

  def test_first
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` ASC LIMIT 1"
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
      "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id} ORDER BY `articles`.`id` DESC LIMIT 1"
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

  def test_to_a
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `articles`.* FROM `articles` WHERE `articles`.`user_id` = #{user.id}"
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
end
