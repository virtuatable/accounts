module Utils
  # This class loads the necessary data in the database if they don't exist yet.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Seeder
    include Singleton

    # Creates the service if it does not exist, and the instance if it does not exist.
    # @return [Arkaan::Monitoring::Service] the created, or found, service corresponding to this micro-service.
    def create_service(key)
      service = Arkaan::Monitoring::Service.where(key: key).first

      if service.nil?
        service = Arkaan::Monitoring::Service.create!(key: key, path: "/#{key}", premium: true, active: true)
      end

      if service.instances.where(url: ENV['SERVICE_URL']).first.nil?
        Arkaan::Monitoring::Instance.create!(url: ENV['SERVICE_URL'], running: true, service: service, active: true)
      end

      return service
    end
  end
end