# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'test_frameworks'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'

require 'lib/mysql2_connection'

require 'acts-as-taggable-on'

require 'adaptive_alias'
require 'lib/identity_cache'
require 'lib/seeds'

Warning[:deprecated] = false if Warning.respond_to?(:[]) # Warning#[] is not defined in Ruby 2.6.
$VERBOSE = nil

def assert_queries(expected, event_key = 'sql.active_record')
  sqls = []
  subscriber = ActiveSupport::Notifications.subscribe(event_key) do |_, _, _, _, payload|
    sqls << "#{payload[:sql]}" if payload[:sql] !~ /\A(?:BEGIN TRANSACTION|COMMIT TRANSACTION|BEGIN|COMMIT)\z|FROM information_schema\.tables|SHOW FULL FIELDS/i
  end

  yield
  expected = expected.call if expected.is_a?(Proc)

  case expected
  when Integer
    if expected != sqls.size # show all sql queries if query count doesn't equal to expected count.
      assert_equal "expect #{expected} queries, but have #{sqls.size}", "\n#{sqls.join("\n").tr('"', "'")}\n"
    end

    assert_equal expected, sqls.size
  when Array
    assert_equal expected, sqls
  end
ensure
  ActiveSupport::Notifications.unsubscribe(subscriber)
end

# aliased column name is changed in Rails 7.0
def alias_name_wrapping(column_name)
  return column_name if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new('7.0.0')
  return "`#{column_name}`"
end

def with_rollback
  ActiveRecord::Base.transaction do
    yield
    fail ActiveRecord::Rollback
  end
end

def assert_queries_and_rollback(expected, event_key = 'sql.active_record')
  with_rollback do
    assert_queries(expected, event_key) do
      yield
    end
  end
end

# make suer to rollback db schema even if some test cases fail
def restore_original_db_schema!(klass, old_column, new_column, forward = true)
  begin
    klass.connection.rename_column klass.table_name, new_column, old_column
  rescue
  end

  key = forward ? [klass, old_column, new_column] : [klass, new_column, old_column]
  patch = AdaptiveAlias.current_patches[key]

  expected_patch_klass = forward ? AdaptiveAlias::Patches::ForwardPatch : AdaptiveAlias::Patches::BackwardPatch
  patch.remove! if not patch.is_a?(expected_patch_klass)
end
