require 'test_helper'

class ColumnNamesTest < Minitest::Test
  def setup
    restore_original_db_schema!(Article, :user_id, :user_id_abc)
  end

  def test_column_names
    assert_equal %w[id user_id title active], Article.column_names

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_equal %w[id user_id title active], Article.column_names
      Article.last.user_id
      assert_equal %w[id user_id_abc title active], Article.column_names

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_equal %w[id user_id_abc title active], Article.column_names
      Article.last.user_id_abc
      assert_equal %w[id user_id title active], Article.column_names
    end
  end

  def test_attribute_names
    assert_equal %w[id user_id title active], Article.attribute_names

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_equal %w[id user_id title active], Article.attribute_names
      Article.last.user_id
      assert_equal %w[id user_id_abc title active], Article.attribute_names

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_equal %w[id user_id_abc title active], Article.attribute_names
      Article.last.user_id_abc
      assert_equal %w[id user_id title active], Article.attribute_names
    end
  end

  def test_instance_attribute_names
    assert_equal %w[id user_id title active], Article.last.attribute_names

    3.times do
      # --------- do rename migration ---------
      Article.connection.rename_column :articles, :user_id, :user_id_abc
      assert_equal %w[id user_id_abc title active], Article.last.attribute_names

      # --------- rollback rename migration ---------
      Article.connection.rename_column :articles, :user_id_abc, :user_id
      assert_equal %w[id user_id title active], Article.last.attribute_names
    end
  end
end
