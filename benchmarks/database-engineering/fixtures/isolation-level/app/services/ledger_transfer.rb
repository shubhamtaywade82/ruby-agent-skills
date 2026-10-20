# frozen_string_literal: true

# Naive starting point: plain reads, an arity guard, and unconditional writes
# with no transaction, no row locks, no isolation configuration, and no
# handling for serialization or deadlock aborts.
class LedgerTransfer
  class InsufficientFunds < StandardError; end

  def self.call(db, from_id:, to_id:, amount:, externals: nil)
    from_balance = db.read(from_id)
    to_balance = db.read(to_id)
    raise InsufficientFunds, "account #{from_id} cannot cover #{amount}" if from_balance < amount

    db.write(from_id, from_balance - amount)
    db.write(to_id, to_balance + amount)
    nil
  end
end
