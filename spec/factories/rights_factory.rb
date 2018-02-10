FactoryGirl.define do
  factory :empty_right, class: Arkaan::Permissions::Right do
    factory :right do
      slug 'test_right'
    end
  end
end