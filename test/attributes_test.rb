require 'test_helper'

class ProfileTest < Minitest::Test
  def setup
  end

  def teardown
    # make suer to rollback db schema even if some test cases fail
    Article.connection.rename_column :users, :profile_id_new, :profile_id
  rescue
    nil
  end

  def test_access
    user = User.find_by(name: 'Catty')
    profile_id = user.profile.id

    assert_queries(0) do
      assert_equal profile_id, user.profile_id_new
      assert_equal profile_id, user.profile_id
    end

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :users, :profile_id, :profile_id_new
      user = User.find_by(name: 'Catty')
      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
        assert_equal profile_id, user.profile_id
      end

      # --------- rollback rename migration ---------
      Article.connection.rename_column :users, :profile_id_new, :profile_id
      user = User.find_by(name: 'Catty')
      assert_queries(0) do
        assert_equal profile_id, user.profile_id_new
        assert_equal profile_id, user.profile_id
      end
    end
  end
end
