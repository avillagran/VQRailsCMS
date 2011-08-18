# -*- encoding : utf-8 -*-
class Admin::CategoriesController < Admin::AdminController

  def index
    @items = Category.all
  end

  def show
    @item = Category.find(params[:id])
  end

  def new
    @item = Category.new
  end

  def edit
    @item = Category.find(params[:id])
  end

  def create
    @item = Category.new(params[:category])

    if @item.save
      redirect_to(admin_category_path(@item), :notice => 'Categoria creada.')
    else
      render :action => "new"
    end

  end

  def update
    @item = Category.find(params[:id])

    if @item.update_attributes(params[:category])
      redirect_to(admin_category_path(@item), :notice => 'Categoria actualizada')
    else
      render :action => "edit"
    end
  end

  def destroy
    @item = Category.find(params[:id])
    @item.destroy

    redirect_to(admin_categories_url)
  end
end
