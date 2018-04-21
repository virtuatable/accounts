FactoryGirl.define do
  factory :empty_phone, class: Arkaan::Phone do
    factory :phone do
      id 'phone_id'
      number '06.07.08.09.10'
      privacy :players
    end
  end
end