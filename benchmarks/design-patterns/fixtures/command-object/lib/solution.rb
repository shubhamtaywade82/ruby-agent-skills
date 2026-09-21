class User
  attr_accessor :active
  def initialize
    @active = true
  end
end

class User::Deactivate
  def initialize(user)
    @user = user
  end

  def call
    raise NotImplementedError
  end
end
