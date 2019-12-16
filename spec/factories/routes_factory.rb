FactoryBot.define do
  factory :empty_route, class: Arkaan::Monitoring::Route do
    factory :route do
      path { '/route' }
      verb { 'post' }
    end
  end
end