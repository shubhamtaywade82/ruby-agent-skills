class BackfillNormalizedEmail
  BATCH_SIZE = 500

  def self.run
    User.where(normalized_email: nil).in_batches(of: BATCH_SIZE) do |batch|
      batch.update_all("normalized_email = LOWER(email)")
    end
  end
end
