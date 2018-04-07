module Decorators
  class Account < Draper::Decorator
    delegate_all

    def to_json
      return to_h.to_json
    end

    def to_h
      return {
        id: _id.to_s,
        username: username,
        lastname: lastname,
        firstname: firstname,
        email: email,
        birthdate: birthdate.utc.iso8601,
        rights: get_rights
      }
    end

    def get_rights
      return get_raw_rights.flatten
    end

    def get_raw_rights
      object.groups.map do |group|
        Decorators::Right.decorate_collection(group.rights).map(&:to_h)
      end
    end

  end
end