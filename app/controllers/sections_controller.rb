# -*- encoding : utf-8 -*-
class SectionsController < ApplicationController
  before_filter :store_location, :only => [:index, :show]

  def index
    @items = Section.status_published
  end

  def show
    @item = Section.find(params[:id])

    set_meta :title => @item.title
    set_meta :image => @item.image.url if @item.image.exists?

    @items = nil

    if @item.kind == "list"
      @items = @item.articles.status_published.paginate :page => params[:page], :per_page => params[:per_page] || Article::per_page
    end

    unless @item.template.blank?
      render @item.template
    end
  end
end
