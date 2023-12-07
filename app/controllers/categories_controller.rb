class CategoriesController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  def index
    @categories = Category.all
  end

  def show
    @category = Category.find(params[:id])
    @total_amount = @category.total_amount
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to categories_path, notice: 'Category created successfully!'
    else
      render 'new'
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :icon)
  end
end
