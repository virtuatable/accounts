module Services
  class Accounts
    include Singleton

    def create(parameters)
      account = Arkaan::Account.new(parameters)
      account.groups = Arkaan::Permissions::Group.where(is_default: true)
      return account
    end
  end
end