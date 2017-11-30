module Decorators
  class Account < Draper::Decorator
    delegate_all
    decorates_finders

    def match_password(password)
      return BCrypt::Password.new(password_digest) == password
    end
  end
end