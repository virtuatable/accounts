class ServiceDecorator < Draper::Decorator
  delegate_all

  attr_accessor :instances

  def initialize(service)
    @instances = service.instances
  end

  def forward_without_id(request)
    forward(request, '/')
  end

  def forward_with_id(request, id)
    forward(request, "/#{id}")
  end

  private

  def forward(request, path)
    Faraday.new(url: instances.sample.url).send(request.env['REQUEST_METHOD'].downcase, url)
  end
end