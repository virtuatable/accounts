FactoryGirl.define do
  factory :empty_account, class: Arkaan::Account do
    factory :account do
      _id 'account_id'
      username 'Autre compte'
      password 'password'
      password_confirmation 'password'
      email 'machin@test.com'
      lastname 'Courtois'
      firstname 'Vincent'
      birthdate DateTime.new(1989, 8, 29, 21, 50)

      factory :other_account do
        _id 'other_account_id'
      end
    end
  end
end