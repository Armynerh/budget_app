# app/models/budget_transaction.rb
class BudgetTransaction < ApplicationRecord
  belongs_to :user, foreign_key: 'author_id'
  belongs_to :category

  validates :name, presence: true
  validates :amount, presence: true
  validates :category, presence: true
end
