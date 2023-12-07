# app/controllers/budget_transactions_controller.rb
class BudgetTransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:index, :new, :create]

  def index
    @budget_transactions = @category.budget_transactions.order(created_at: :desc)
    @total_amount = @category.total_amount
    @category_info = {
      name: @category.name,
      icon: @category.icon
    }
  end

  def new
    @budget_transaction = @category.budget_transactions.build
  end

  def create
    @budget_transaction = @category.budget_transactions.build(budget_transaction_params)
    @budget_transaction.user = current_user

    if @budget_transaction.save
      redirect_to category_budget_transactions_path(@category), notice: 'Transaction created successfully!'
    else
      render 'new'
    end
  end

  private

  def set_category
    @category = Category.find_by(id: params[:category_id])

    unless @category
      redirect_to categories_path, alert: 'Category not found'
    end
  end

  def budget_transaction_params
    params.require(:budget_transaction).permit(:name, :amount)
  end
end
