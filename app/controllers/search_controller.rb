# -*- encoding : utf-8 -*-
class SearchController < ApplicationController
  before_filter :store_location, :only => [:index]

  def index
    search = params[:q]
    search = search.gsub('%','\%').gsub('_','\_') unless params[:q].nil?
    search = '%'+search+'%'

    @items = Article.status_published.where('title LIKE ? OR content LIKE ?', search, search).order("created_at DESC").paginate :page => params[:page], :per_page => params[:per_page] || 20
  end

end
