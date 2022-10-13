require 'test_helper'

class RawSqlQueryTest < Minitest::Test
  def setup
  end

  def teardown
    restore_original_db_schema!(User, :profile_id, :profile_id_new)
  end

  def test_select
    assert_queries([
      'SELECT `users`.`profile_id` FROM users WHERE `users`.`profile_id` = 1',
    ]) do
      AdaptiveAlias.rescue_statement_invalid do
        profile_id_column_name = User.attribute_aliases['profile_id_new'] || 'profile_id_new'
        sql = <<~SQL.squish
          SELECT `users`.`#{profile_id_column_name}` FROM users WHERE `users`.`#{profile_id_column_name}` = 1
        SQL

        assert_equal [[1]], ActiveRecord::Base.connection.execute(sql).to_a
      end
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries([
        'SELECT `users`.`profile_id` FROM users WHERE `users`.`profile_id` = 1',
        'SELECT `users`.`profile_id_new` FROM users WHERE `users`.`profile_id_new` = 1',
      ]) do
        AdaptiveAlias.rescue_statement_invalid do
          profile_id_column_name = User.attribute_aliases['profile_id_new'] || 'profile_id_new'
          sql = <<~SQL.squish
            SELECT `users`.`#{profile_id_column_name}` FROM users WHERE `users`.`#{profile_id_column_name}` = 1
          SQL

          assert_equal [[1]], ActiveRecord::Base.connection.execute(sql).to_a
        end
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries([
        'SELECT `users`.`profile_id_new` FROM users WHERE `users`.`profile_id_new` = 1',
        'SELECT `users`.`profile_id` FROM users WHERE `users`.`profile_id` = 1',
      ]) do
        AdaptiveAlias.rescue_statement_invalid do
          profile_id_column_name = User.attribute_aliases['profile_id_new'] || 'profile_id_new'
          sql = <<~SQL.squish
            SELECT `users`.`#{profile_id_column_name}` FROM users WHERE `users`.`#{profile_id_column_name}` = 1
          SQL

          assert_equal [[1]], ActiveRecord::Base.connection.execute(sql).to_a
        end
      end
    end
  end

  def test_update
    assert_queries_and_rollback([
      'UPDATE `users` SET `users`.`profile_id` = 222 WHERE `users`.`profile_id` = 1',
    ]) do
      AdaptiveAlias.rescue_statement_invalid do
        profile_id_column_name = User.attribute_aliases['profile_id_new'] || 'profile_id_new'
        sql = <<~SQL.squish
          UPDATE `users` SET `users`.`#{profile_id_column_name}` = 222 WHERE `users`.`#{profile_id_column_name}` = 1
        SQL

        assert_equal nil, ActiveRecord::Base.connection.execute(sql)
      end
    end

    3.times do
      # --------- do rename migration ---------
      User.connection.rename_column :users, :profile_id, :profile_id_new

      assert_queries_and_rollback([
        'UPDATE `users` SET `users`.`profile_id` = 222 WHERE `users`.`profile_id` = 1',
        'UPDATE `users` SET `users`.`profile_id_new` = 222 WHERE `users`.`profile_id_new` = 1',
      ]) do
        AdaptiveAlias.rescue_statement_invalid do
          profile_id_column_name = User.attribute_aliases['profile_id_new'] || 'profile_id_new'
          sql = <<~SQL.squish
            UPDATE `users` SET `users`.`#{profile_id_column_name}` = 222 WHERE `users`.`#{profile_id_column_name}` = 1
          SQL

          assert_equal nil, ActiveRecord::Base.connection.execute(sql)
        end
      end

      # --------- rollback rename migration ---------
      User.connection.rename_column :users, :profile_id_new, :profile_id

      assert_queries_and_rollback([
        'UPDATE `users` SET `users`.`profile_id_new` = 222 WHERE `users`.`profile_id_new` = 1',
        'UPDATE `users` SET `users`.`profile_id` = 222 WHERE `users`.`profile_id` = 1',
      ]) do
        AdaptiveAlias.rescue_statement_invalid do
          profile_id_column_name = User.attribute_aliases['profile_id_new'] || 'profile_id_new'
          sql = <<~SQL.squish
            UPDATE `users` SET `users`.`#{profile_id_column_name}` = 222 WHERE `users`.`#{profile_id_column_name}` = 1
          SQL

          assert_equal nil, ActiveRecord::Base.connection.execute(sql)
        end
      end
    end
  end
end
