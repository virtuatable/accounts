ENV['SERVICE_URL'] = 'https://service-sessions.com'

RSpec.describe Utils::Seeder do

  let!(:seeder) { Utils::Seeder.instance }

  describe :create_service do
    describe 'check beginning environment' do
      it 'starts with an empty environment for the services' do
        expect(Arkaan::Monitoring::Service.all.count).to be 0
      end
      it 'starts with an empty environment for the instances' do
        expect(Arkaan::Monitoring::Instance.all.count).to be 0
      end
    end
    describe 'start with an empty environment' do
      let!(:service) { seeder.create_service('sessions') }

      it 'creates a service correctly' do
        expect(Arkaan::Monitoring::Service.all.count).to be 1
      end
      it 'creates a service with the right key' do
        expect(service.key).to eq 'sessions'
      end
      it 'creates a service with the right path' do
        expect(service.path).to eq '/sessions'
      end
      it 'creates a premium service correctly' do
        expect(service.premium).to be true
      end
      it 'creates an instance correctly' do
        expect(service.instances.count).to be 1
      end
      it 'creates an instance with the correct url' do
        expect(service.instances.first.url).to eq ENV['SERVICE_URL']
      end
    end
    describe 'start with a filled environment' do
      before(:each) do
        @service = Arkaan::Monitoring::Service.create!(key: 'sessions', path: '/other', premium: false)
        @instance = Arkaan::Monitoring::Instance.create!(url: ENV['SERVICE_URL'], service: @service)
      end
      it 'does not create an additional service' do
        seeder.create_service('sessions')
        expect(Arkaan::Monitoring::Service.all.count).to be 1
      end
      it 'returns the service with the already set path' do
        expect(seeder.create_service('sessions').path).to eq '/other'
      end
      it 'returns the service with the already set premium path' do
        expect(seeder.create_service('sessions').premium).to be false
      end
      it 'does not create an additional instance' do
        service = seeder.create_service('sessions')
        expect(service.instances.count).to be 1
      end
    end
    describe 'start with only a service in the database' do
      before(:each) do
        @service = Arkaan::Monitoring::Service.create!(key: 'sessions', path: '/other', premium: false)
        @instance = Arkaan::Monitoring::Instance.create!(url: 'https://other-url.com/', service: @service)
      end
      it 'does not create an additional service' do
        seeder.create_service('sessions')
        expect(Arkaan::Monitoring::Service.all.count).to be 1
      end
      it 'returns the service with the already set path' do
        expect(seeder.create_service('sessions').path).to eq '/other'
      end
      it 'returns the service with the already set premium path' do
        expect(seeder.create_service('sessions').premium).to be false
      end
      it 'does create an additional instance' do
        expect(seeder.create_service('sessions').instances.count).to be 2
      end
    end
  end
end