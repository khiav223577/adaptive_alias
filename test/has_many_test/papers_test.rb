require 'test_helper'

class PapersTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(Paper, :new_user_id, :user_id, false)
  end

  def test_first
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} ORDER BY `papers`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'Paper B1', user.papers.first.title
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} ORDER BY `papers`.`id` ASC LIMIT 1",
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`user_id` = #{user.id} ORDER BY `papers`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Paper B1', user.papers.first.title
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`user_id` = #{user.id} ORDER BY `papers`.`id` ASC LIMIT 1",
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} ORDER BY `papers`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'Paper B1', user.papers.first.title
      end
    end
  end

  def test_last
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} ORDER BY `papers`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'Paper B3', user.papers.last.title
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id

      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} ORDER BY `papers`.`id` DESC LIMIT 1",
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`user_id` = #{user.id} ORDER BY `papers`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Paper B3', user.papers.last.title
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`user_id` = #{user.id} ORDER BY `papers`.`id` DESC LIMIT 1",
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} ORDER BY `papers`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'Paper B3', user.papers.last.title
      end
    end
  end

  def test_to_a
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id}",
    ]) do
      assert_equal ['Paper B1', 'Paper B2', 'Paper B3'], user.papers.map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id}",
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Paper B1', 'Paper B2', 'Paper B3'], user.papers.map(&:title)
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`user_id` = #{user.id}",
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id}",
      ]) do
        assert_equal ['Paper B1', 'Paper B2', 'Paper B3'], user.papers.map(&:title)
      end
    end
  end

  def test_to_a_with_default_scope
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} AND `papers`.`active` = TRUE",
    ]) do
      assert_equal ['Paper B2'], user.active_papers.map(&:title)
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} AND `papers`.`active` = TRUE",
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`user_id` = #{user.id} AND `papers`.`active` = TRUE",
      ]) do
        assert_equal ['Paper B2'], user.active_papers.map(&:title)
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`user_id` = #{user.id} AND `papers`.`active` = TRUE",
        "SELECT `papers`.* FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} AND `papers`.`active` = TRUE",
      ]) do
        assert_equal ['Paper B2'], user.active_papers.map(&:title)
      end
    end
  end

  def test_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `papers`.`title` FROM `papers` WHERE `papers`.`new_user_id` = #{user.id}",
    ]) do
      assert_equal ['Paper B1', 'Paper B2', 'Paper B3'], user.papers.pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.`title` FROM `papers` WHERE `papers`.`new_user_id` = #{user.id}",
        "SELECT `papers`.`title` FROM `papers` WHERE `papers`.`user_id` = #{user.id}",
      ]) do
        assert_equal ['Paper B1', 'Paper B2', 'Paper B3'], user.papers.pluck(:title)
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.`title` FROM `papers` WHERE `papers`.`user_id` = #{user.id}",
        "SELECT `papers`.`title` FROM `papers` WHERE `papers`.`new_user_id` = #{user.id}",
      ]) do
        assert_equal ['Paper B1', 'Paper B2', 'Paper B3'], user.papers.pluck(:title)
      end
    end
  end

  def test_where_and_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `papers`.`title` FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} AND `papers`.`active` = TRUE",
    ]) do
      assert_equal ['Paper B2'], user.papers.where(active: true).pluck(:title)
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.`title` FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} AND `papers`.`active` = TRUE",
        "SELECT `papers`.`title` FROM `papers` WHERE `papers`.`user_id` = #{user.id} AND `papers`.`active` = TRUE",
      ]) do
        assert_equal ['Paper B2'], user.papers.where(active: true).pluck(:title)
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `papers`.`title` FROM `papers` WHERE `papers`.`user_id` = #{user.id} AND `papers`.`active` = TRUE",
        "SELECT `papers`.`title` FROM `papers` WHERE `papers`.`new_user_id` = #{user.id} AND `papers`.`active` = TRUE",
      ]) do
        assert_equal ['Paper B2'], user.papers.where(active: true).pluck(:title)
      end
    end
  end

  def test_create
    user = User.find_by(name: 'Catty')
    post = nil

    assert_queries([
      "INSERT INTO `papers` (`new_user_id`, `title`) VALUES (2, 'new post')",
    ]) do
      post = user.papers.create!(title: 'new post')
    end

    post.destroy
    post = nil

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "INSERT INTO `papers` (`new_user_id`, `title`) VALUES (2, 'new post')",
        'ROLLBACK',
        "INSERT INTO `papers` (`user_id`, `title`) VALUES (2, 'new post')",
      ]) do
        post = user.papers.create!(title: 'new post')
      end

      post.destroy
      post = nil

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "INSERT INTO `papers` (`user_id`, `title`) VALUES (2, 'new post')",
        'ROLLBACK',
        "INSERT INTO `papers` (`new_user_id`, `title`) VALUES (2, 'new post')",
      ]) do
        post = user.papers.create!(title: 'new post')
      end

      post.destroy
      post = nil
    end
  ensure
    post.destroy if post
  end

  def test_destroy
    user = User.find_by(name: 'Catty')
    papers = Array.new(7){ user.papers.create!(title: 'new post') }

    assert_queries([
      "DELETE FROM `papers` WHERE `papers`.`id` = #{papers.last.id}",
    ]) do
      papers.pop.destroy!
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      assert_queries([
        "DELETE FROM `papers` WHERE `papers`.`id` = #{papers.last.id}",
      ]) do
        papers.pop.destroy!
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      assert_queries([
        "DELETE FROM `papers` WHERE `papers`.`id` = #{papers.last.id}",
      ]) do
        papers.pop.destroy!
      end
    end
  ensure
    papers.each(&:destroy!)
    papers.clear
  end
end
