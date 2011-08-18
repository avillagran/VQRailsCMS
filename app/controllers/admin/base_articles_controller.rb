# -*- encoding : utf-8 -*-
class Admin::BaseArticlesController < Admin::AdminController
  uses_tiny_mce :only => [:new, :edit]

  def index
    @items = Section.all(:conditions => {:kind => 'list'}, :order => 'title')
  end

  def section
    @section = Section.find(params[:section_id])
    @items = @section.articles
  end

  def show
    @item = Article.find(params[:id])
    @item[:title] = @item.title
    @item[:content] = @item.content
  end

  def new
    @item = Article.new(params[:article])
  end

  def edit
    @item = Article.find(params[:id])
    @item[:title] = @item.title
    @item[:content] = @item.content
  end

  def create
    #cl = category_alter_param

    item = params[:article]
    item_translations = prepare_translations(item, :article_translations)
    assets = prepare_asset(item)

    @item = Article.new(item)
    #@item.category_list = cl

    if @item.save
      item_translations.each do |k, i|
        translation(@item, i)
      end
      save_asset(@item, assets)
      redirect_to(admin_article_path(@item), :notice => 'Article was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @item = Article.find(params[:id])

    #cl = category_alter_param

    item = params[:article]
    item_translations = prepare_translations(item, :article_translations)
    assets = prepare_asset(item)

    if @item.update_attributes(item)
      #@item.category_list = cl
      #@item.save
      item_translations.each do |k, i|
        translation(@item, i)
      end
      save_asset(@item, assets)
      redirect_to(admin_article_path(@item), :notice => 'Article was successfully updated.')
    else
      @item[:title] = @item.title
      @item[:content] = @item.content

      render :action => "edit"
    end
  end

  def destroy
    @item = Article.find(params[:id])
    @item.destroy

    redirect_to(admin_articles_path)
  end

  def translation(item, section_translation)
    st = section_translation
    r = get_translation(item, st[:locale])
    r.update_attributes(st)
    r.save(:validate => false)
  end



end
