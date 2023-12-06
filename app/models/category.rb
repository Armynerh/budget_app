class Category < ApplicationRecord
  has_and_belongs_to_many :users
  has_and_belongs_to_many :budget_transactions

  validates :name, presence: true
  validates :icon, presence: true
end
