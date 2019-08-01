# frozen_string_literal: true

module Services
  # Service concerning accounts, creating them from raw parameters hashes.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Accounts
    include Singleton

    def create(parameters)
      account = Arkaan::Account.new(parameters)
      account.groups = Arkaan::Permissions::Group.where(is_default: true)
      account
    end
  end
end
