# frozen_string_literal: true

module Decorators
  # Represents a right the user has on the frontend side (not a route access).
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Right < Virtuatable::Enhancers::Base
    enhances Arkaan::Permissions::Right

    def to_h
      {
        id: object.id.to_s,
        slug: "#{object.category.slug}.#{object.slug}"
      }
    end
  end
end
