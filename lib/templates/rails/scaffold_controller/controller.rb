# -*- encoding : utf-8 -*-
class <%= controller_class_name %>Controller < ApplicationController

  def index
    @items = <%= orm_class.all(class_name) %>
  end

  def show
    @item = <%= orm_class.find(class_name, "params[:id]") %>
  end

  def new
    @item = <%= orm_class.build(class_name) %>
  end

  def edit
    @item = <%= orm_class.find(class_name, "params[:id]") %>
  end

  def create
    @item = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>

    if @item.save
      redirect_to @item, :notice => "<%= human_name %> ha sido creado."
    else
      render :action => "new"
    end
  end

  def update
    @item = <%= orm_class.find(class_name, "params[:id]") %>

    if @item.update_attributes(params[:<%=singular_table_name%>])
      redirect_to @item, :notice => "<%= human_name %> ha sido actualizado."
    else
      render :action => "edit"
    end
  end

  def destroy
    @item = <%= orm_class.find(class_name, "params[:id]") %>
    @item.destroy

    redirect_to <%= index_helper %>_url
  end
end
