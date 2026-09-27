require "minitest/autorun"
require_relative "../lib/user"
require_relative "../lib/post/creator"

class PostCreatorTest < Minitest::Test
  def test_creates_and_appends_post
    user = User.new
    post = Post::Creator.call(user, status_text: "Howdy")
    assert_instance_of Post, post
    assert_equal "Howdy", post.status.text
    assert_equal [post], user.posts
  end

  def test_blank_status_creates_nothing
    user = User.new
    assert_raises(ArgumentError) { Post::Creator.call(user, status_text: "  ") }
    assert_empty user.posts
  end

  def test_nil_user_fails_predictably
    assert_raises(ArgumentError) { Post::Creator.call(nil, status_text: "Howdy") }
  end
end
