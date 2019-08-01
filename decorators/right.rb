# frozen_string_literal: true

module Decorators
  # Represents a right the user has on the frontend side (not a route access).
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Right < Draper::Decorator
    delegate_all

    def to_h
      {
        id: object.id.to_s,
        slug: "#{object.category.slug}.#{object.slug}"
      }
    end
  end
end
