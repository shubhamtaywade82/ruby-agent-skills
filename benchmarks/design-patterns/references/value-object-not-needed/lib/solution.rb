class EmailValidator
  def valid?(email)
    email.include?("@") && email.split("@").last.include?(".")
  end
end
