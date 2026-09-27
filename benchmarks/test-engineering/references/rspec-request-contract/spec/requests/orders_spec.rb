require "rails_helper"

RSpec.describe "POST /orders", type: :request do
  # The 422 contract every JSON write endpoint shares; reuse it with it_behaves_like.
  shared_examples "a rejected JSON write" do |attribute:, type:|
    it "returns 422 with the Rails validation error shape" do
      make_request

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.fetch("errors")).to include(
        a_hash_including("attribute" => attribute, "type" => type)
      )
    end

    it "does not persist anything" do
      expect { make_request }.not_to change(Order, :count)
    end
  end

  let(:headers) { { "ACCEPT" => "application/json" } }

  context "with valid params" do
    let(:params) { { order: { sku: "BOOK-1", quantity: 2, email: "a@example.com" } } }

    it "creates the order" do
      expect { post orders_path, params: params, headers: headers }.to change(Order, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to eq("id" => Order.last.id, "status" => "pending")
    end

    it "enqueues fulfilment and the confirmation email" do
      # Block form: have_enqueued_mail raises ArgumentError without a block.
      expect { post orders_path, params: params, headers: headers }
        .to have_enqueued_job(FulfilOrderJob).with(an_instance_of(Order)).on_queue("fulfilment")
        .and have_enqueued_mail(OrderMailer, :confirmation).with(an_instance_of(Order))
    end
  end

  context "with a non-positive quantity" do
    subject(:make_request) do
      post orders_path, params: { order: { sku: "BOOK-1", quantity: 0, email: "a@example.com" } }, headers: headers
    end

    it_behaves_like "a rejected JSON write", attribute: "quantity", type: "greater_than"
  end
end
