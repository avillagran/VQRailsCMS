# -*- encoding : utf-8 -*-
class SiteController < SitebaseController
  def index
    @sections = Section.all
  end
  def products
    @items = Article.tagged_with("Productos", :on => :categories, :conditions => {:status => 'published'}).all
  end
end
