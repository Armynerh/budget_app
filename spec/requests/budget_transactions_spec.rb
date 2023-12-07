require 'rails_helper'

RSpec.describe "BudgetTransactions", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/budget_transactions/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/budget_transactions/create"
      expect(response).to have_http_status(:success)
    end
  end

end
