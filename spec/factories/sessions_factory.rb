FactoryGirl.define do
  factory :empty_session, class: Arkaan::Authentication::Session do
    factory :session do
      expiration 3600
      token 'session_token'
    end
  end
end