require 'test_helper'

class HasManyAssociationTest < Minitest::Test
  def setup
  end

  def test_to_a
    assert_equal ['Post B1', 'Post B2'], User.find_by(name: 'Catty').posts.map(&:title)
  end
end
