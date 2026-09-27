User = Struct.new(:first_name, :last_name, :tier)

class UserPresenter
  def initialize(user)
    @user = user
  end

  def display_name
    [@user.first_name, @user.last_name].compact.join(" ")
  end

  def membership_label
    @user.tier.to_s.capitalize
  end
end
