class BackfillNormalizedEmail
  def self.run
    User.all.each do |user|
      user.update!(normalized_email: user.email.downcase)
    end
  end
end
