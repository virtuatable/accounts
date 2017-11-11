module Decorators
  class Account < Draper::Decorator
    delegate_all
    decorates_finders

    def authenticate(password)

    end
  end
end