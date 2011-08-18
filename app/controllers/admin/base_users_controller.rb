# -*- encoding : utf-8 -*-
class Admin::BaseUsersController < Admin::AdminController

  def index
    @items = User.all
  end

  def show
    @item = User.find(params[:id])
  end

  def new
    @item = User.new
  end

  def edit
    @item = User.find(params[:id])
  end

  def create
    #cl = category_alter_param
    item = User.new(params[:user])
    #item.category_list = cl

    if item.save
      redirect_to(admin_users_path, :notice => 'User was successfully created.')

    else
      render :action => "new"
    end
  end

  def update
    @item = User.find(params[:id])
    #cl = category_alter_param

    if @item.update_attributes(params[:user])
      #@item.category_list = cl
      @item.save
      redirect_to(admin_users_path, :notice => 'User was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @item = User.find(params[:id])
    @item.destroy

    redirect_to(admin_users_path)
  end

end
