class Post
  attr_reader :user, :status

  def initialize(user:, status:)
    @user = user
    @status = status
  end
end
