require "rails_helper"

RSpec.describe OrdersController, type: :controller do
  it "creates an order" do
    allow_any_instance_of(Order).to receive(:save).and_return(true)
    post :create, params: { order: { sku: "SKU-1", quantity: 1 } }
    expect(assigns(:order).sku).to eq("SKU-1")
    expect(OrderMailer).to have_enqueued_mail(OrderMailer, :confirmation)
  end
end
