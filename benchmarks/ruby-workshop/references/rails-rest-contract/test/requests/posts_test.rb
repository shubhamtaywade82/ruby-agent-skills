require "test_helper"

class PostsTest < ActionDispatch::IntegrationTest
  test "creates a post through permitted parameters only" do
    post posts_url, params: { post: { title: "Hello", body: "World", admin: true } }, as: :json
    assert_response :created
    assert_equal "Hello", response.parsed_body["title"]
    refute response.parsed_body.key?("admin")
  end

  test "rejects a request without the post root key" do
    post posts_url, params: { title: "Hello" }, as: :json
    assert_response :bad_request
  end

  test "updates, shows, lists, and destroys" do
    record = Post.create!(title: "Old", body: "Body")
    patch post_url(record), params: { post: { title: "New" } }, as: :json
    assert_response :success
    get post_url(record), as: :json
    assert_equal "New", response.parsed_body["title"]
    get posts_url, as: :json
    assert_response :success
    delete post_url(record), as: :json
    assert_response :no_content
  end
end
