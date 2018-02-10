FactoryGirl.define do
  factory :empty_category, class: Arkaan::Permissions::Category do
    factory :category do
      slug 'test_category'
    end
  end
end