class ServiceController < Sinatra::Base

  register Sinatra::MultiRoute

  attr_reader :custom_service

  def initialize(custom_service)
    super
    @custom_service = ServiceDecorator.new(custom_service)
  end

  route :get, :post, '/' do
    forwarded = custom_service.forward_without_id
    status forwarded.status
    body   forwarded.body
  end

  route :get, :put, :delete, "/:id" do
    forwarded = custom_service.forward_with_id(request, params[:id])
    status forwarded.status
    body   forwarded.body
  end
end