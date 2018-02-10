FactoryGirl.define do
  factory :empty_service, class: Arkaan::Monitoring::Service do
    factory :service do
      key 'test.service'
      path '/example'
      diagnostic '/status'
    end
  end
end