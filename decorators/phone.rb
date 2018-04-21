module Decorators
  class Phone < Draper::Decorator
    delegate_all

    def to_h
      return {
        id: object.id,
        number: object.number,
        privacy: object.privacy
      }
    end
  end
end