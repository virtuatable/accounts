FactoryBot.define do
  factory :empty_group, class: Arkaan::Permissions::Group do
    factory :group do
      slug { 'test_group' }

      factory :default_group do
        is_default { true }
      end
    end
  end
end