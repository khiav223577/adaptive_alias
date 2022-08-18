require 'test_helper'

class PapersReviewsTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(Paper, :new_user_id, :user_id, false)
  end

  def test_first
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' ORDER BY `reviews`.`id` ASC LIMIT 1",
    ]) do
      assert_equal 'paper review B1', user.papers_reviews.first.content
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' ORDER BY `reviews`.`id` ASC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' ORDER BY `reviews`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'paper review B1', user.papers_reviews.first.content
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' ORDER BY `reviews`.`id` ASC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' ORDER BY `reviews`.`id` ASC LIMIT 1",
      ]) do
        assert_equal 'paper review B1', user.papers_reviews.first.content
      end
    end
  end

  def test_last
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' ORDER BY `reviews`.`id` DESC LIMIT 1",
    ]) do
      assert_equal 'paper review C1', user.papers_reviews.last.content
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' ORDER BY `reviews`.`id` DESC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' ORDER BY `reviews`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'paper review C1', user.papers_reviews.last.content
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' ORDER BY `reviews`.`id` DESC LIMIT 1",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' ORDER BY `reviews`.`id` DESC LIMIT 1",
      ]) do
        assert_equal 'paper review C1', user.papers_reviews.last.content
      end
    end
  end

  def test_to_a
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper'",
    ]) do
      assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], user.papers_reviews.map(&:content)
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper'",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper'",
      ]) do
        assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], user.papers_reviews.map(&:content)
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper'",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper'",
      ]) do
        assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], user.papers_reviews.map(&:content)
      end
    end
  end

  def test_to_a_with_default_scope
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' AND `papers`.`active` = TRUE",
    ]) do
      assert_equal ['paper review C1'], user.active_papers_reviews.map(&:content)
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' AND `papers`.`active` = TRUE",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' AND `papers`.`active` = TRUE",
      ]) do
        assert_equal ['paper review C1'], user.active_papers_reviews.map(&:content)
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' AND `papers`.`active` = TRUE",
        "SELECT `reviews`.* FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' AND `papers`.`active` = TRUE",
      ]) do
        assert_equal ['paper review C1'], user.active_papers_reviews.map(&:content)
      end
    end
  end

  def test_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper'",
    ]) do
      assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], user.papers_reviews.pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper'",
      ]) do
        assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], user.papers_reviews.pluck(:content)
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper'",
      ]) do
        assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], user.papers_reviews.pluck(:content)
      end
    end
  end

  def test_where_and_pluck
    user = User.find_by(name: 'Catty')
    assert_queries([
      "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' AND `papers`.`active` = TRUE",
    ]) do
      assert_equal ['paper review C1'], user.papers_reviews.merge(Paper.where(active: true)).pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' AND `papers`.`active` = TRUE",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' AND `papers`.`active` = TRUE",
      ]) do
        assert_equal ['paper review C1'], user.papers_reviews.merge(Paper.where(active: true)).pluck(:content)
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      user = User.find_by(name: 'Catty')
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' AND `papers`.`active` = TRUE",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `reviews`.`reviewable_id` = `papers`.`id` WHERE `papers`.`new_user_id` = #{user.id} AND `reviews`.`reviewable_type` = 'Paper' AND `papers`.`active` = TRUE",
      ]) do
        assert_equal ['paper review C1'], user.papers_reviews.merge(Paper.where(active: true)).pluck(:content)
      end
    end
  end

  def test_pluck_with_join
    assert_queries([
      "SELECT `content` FROM `users` INNER JOIN `papers` ON `papers`.`new_user_id` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Paper' AND `reviews`.`reviewable_id` = `papers`.`id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], User.joins(papers: :reviews).where(name: 'Catty').pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      assert_queries([
        "SELECT `content` FROM `users` INNER JOIN `papers` ON `papers`.`new_user_id` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Paper' AND `reviews`.`reviewable_id` = `papers`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `content` FROM `users` INNER JOIN `papers` ON `papers`.`user_id` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Paper' AND `reviews`.`reviewable_id` = `papers`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], User.joins(papers: :reviews).where(name: 'Catty').pluck(:content)
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      assert_queries([
        "SELECT `content` FROM `users` INNER JOIN `papers` ON `papers`.`user_id` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Paper' AND `reviews`.`reviewable_id` = `papers`.`id` WHERE `users`.`name` = 'Catty'",
        "SELECT `content` FROM `users` INNER JOIN `papers` ON `papers`.`new_user_id` = `users`.`id` INNER JOIN `reviews` ON `reviews`.`reviewable_type` = 'Paper' AND `reviews`.`reviewable_id` = `papers`.`id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], User.joins(papers: :reviews).where(name: 'Catty').pluck(:content)
      end
    end
  end

  def test_pluck_with_join_reversely
    assert_queries([
      "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `papers`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Paper') INNER JOIN `users` ON `users`.`id` = `papers`.`new_user_id` WHERE `users`.`name` = 'Catty'",
    ]) do
      assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], Review.joins(paper: :user).merge(User.where(name: 'Catty')).pluck(:content)
    end

    3.times do
      # --------- do rename migration ---------
      Paper.connection.rename_column :papers, :new_user_id, :user_id
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `papers`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Paper') INNER JOIN `users` ON `users`.`id` = `papers`.`new_user_id` WHERE `users`.`name` = 'Catty'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `papers`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Paper') INNER JOIN `users` ON `users`.`id` = `papers`.`user_id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], Review.joins(paper: :user).merge(User.where(name: 'Catty')).pluck(:content)
      end

      # --------- rollback rename migration ---------
      Paper.connection.rename_column :papers, :user_id, :new_user_id
      assert_queries([
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `papers`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Paper') INNER JOIN `users` ON `users`.`id` = `papers`.`user_id` WHERE `users`.`name` = 'Catty'",
        "SELECT `reviews`.`content` FROM `reviews` INNER JOIN `papers` ON `papers`.`id` = `reviews`.`reviewable_id` AND (`reviews`.`reviewable_type` = 'Paper') INNER JOIN `users` ON `users`.`id` = `papers`.`new_user_id` WHERE `users`.`name` = 'Catty'",
      ]) do
        assert_equal ['paper review B1', 'paper review B2', 'paper review C1'], Review.joins(paper: :user).merge(User.where(name: 'Catty')).pluck(:content)
      end
    end
  end
end
