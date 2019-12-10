# frozen_string_literal: true

module Decorators
  # Represents an account, with wrapper to easily access its rights.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Account < Virtuatable::Enhancers::Base
    enhances Arkaan::Account

    def to_h
      {
        id: _id.to_s,
        username: username,
        lastname: lastname,
        firstname: firstname,
        email: email,
        gender: gender.to_s,
        language: language.to_s,
        rights: rights
      }
    end

    def rights
      raw_rights.flatten
    end

    def raw_rights
      object.groups.map do |group|
        Decorators::Right.decorate_collection(group.rights).map(&:to_h)
      end
    end
  end
end
