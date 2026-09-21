User = Struct.new(:first_name, :last_name, :tier)

class UserPresenter
  def initialize(user)
    @user = user
  end

  def display_name
    raise NotImplementedError
  end

  def membership_label
    raise NotImplementedError
  end
end
