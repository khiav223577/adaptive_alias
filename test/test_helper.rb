# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'test_frameworks'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'adaptive_alias'
require 'minitest/autorun'

require 'lib/mysql2_connection'

require 'acts-as-taggable-on'
require 'lib/seeds'

Warning[:deprecated] = false if Warning.respond_to?(:[]) # Warning#[] is not defined in Ruby 2.6.
$VERBOSE = nil

def assert_queries(expected, event_key = 'sql.active_record')
  sqls = []
  subscriber = ActiveSupport::Notifications.subscribe(event_key) do |_, _, _, _, payload|
    sqls << "#{payload[:sql]}" if payload[:sql] !~ /\A(?:BEGIN TRANSACTION|COMMIT TRANSACTION|BEGIN|COMMIT)\z|FROM information_schema\.tables|SHOW FULL FIELDS/i
  end

  yield

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

# make suer to rollback db schema even if some test cases fail
def restore_original_db_schema!(klass, old_column, new_column)
  begin
    klass.connection.rename_column klass.table_name, new_column, old_column
  rescue
  end

  patch = AdaptiveAlias.current_patches[[klass, old_column, new_column]]
  patch.remove!.mark_removable if patch.is_a?(AdaptiveAlias::Patches::BackwardPatch)
end
