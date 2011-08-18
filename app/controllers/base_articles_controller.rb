# -*- encoding : utf-8 -*-
class BaseArticlesController < ApplicationController
  before_filter :store_location, :only => [:index, :show]

  def index
    @items = Article.all(:conditions => {:status => 'published'}, :order => "created_at DESC").paginate :page => params[:page], :per_page => 50
  end

  def show
    begin
      @item = Article.find(params[:id])
    rescue
      @item = Section.find(params[:id])
      @items = @item.articles.status_published
    end

    set_meta :title => @item.title, :description => @item.content
    set_meta :image => @item.image.url if @item.image.exists?

    unless @item.template.blank?
      render @item.template
    else
      if @item.class.to_s == "Article" && !@item.section.children_template.blank?
        render @item.section.children_template
      end
    end
  end

  def add_comment
    comm = Comment.new(params[:comment])

    comm.save(false)

    redirect_back_or_default articles_path
  end

end
