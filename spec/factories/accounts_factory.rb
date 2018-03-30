FactoryGirl.define do
  factory :empty_account, class: Arkaan::Account do
    factory :account do
      _id 'account_id'
      username 'Autre compte'
      password 'long_password'
      password_confirmation 'long_password'
      email 'machin@test.com'
      lastname 'Courtois'
      firstname 'Vincent'
      birthdate DateTime.new(1989, 8, 29, 21, 50)

      factory :other_account do
        _id 'other_account_id'
      end

      factory :second_account do
        _id 'second_account_id'
        username 'Second username'
        email 'second@user.com'
      end
    end
  end
end