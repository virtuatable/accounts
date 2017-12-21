module Decorators
  class Account < Draper::Decorator
    delegate_all

    def to_json
      return to_h.to_json
    end

    def to_h
      return {
        username: username,
        password_digest: password_digest,
        lastname: lastname,
        firstname: firstname,
        email: email,
        birthdate: birthdate
      }
    end

  end
end