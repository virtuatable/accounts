# frozen_string_literal: true

module Decorators
  # Empty decorator for groups, allowing to pass through from accounts to rights
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Group < Virtuatable::Enhancers::Base
    enhances Arkaan::Permissions::Group
  end
end
