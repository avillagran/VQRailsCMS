# -*- encoding : utf-8 -*-
class Admin::BaseSectionsController < Admin::AdminController

  def index
    @items = Section.all
  end

  def show
    @item = Section.find(params[:id])
    @item[:title] = @item.title
    @item[:content] = @item.content
  end

  def new
    @item = Section.new
  end

  def edit
    @item = Section.find(params[:id])
    @item[:title] = @item.title
    t = @item.translations.find_by_locale(Settings.default_language.value)
    @item[:content] = t.blank? ? @item.content : t.content
  end

  def create

    item = params[:section]
    item_translations = prepare_translations(item, :section_translations)

    @item = Section.new(item)


    if @item.save
      item_translations.each do |k, i|
        translation(@item, i)
      end
      redirect_to(admin_section_path(@item), :notice => 'Seccion creada.')
    else
      render :action => "new"
    end
=begin
    if @item.save
      redirect_to(admin_section_path(@item), :notice => 'Seccion creada.')
    else
      render :action => "new"
    end
=end
  end

  def update
    @item = Section.find(params[:id])

    item = params[:section]
    item_translations = prepare_translations(item, :section_translations)

    if @item.update_attributes(item)
      item_translations.each do |k, i|
        translation(@item, i)
      end
      redirect_to(admin_section_path(@item), :notice => 'Seccion actualizada')
    else
      @item[:title] = @item.title
      @item[:content] = @item.content
      render :action => "edit"
    end
  end

  def destroy
    @item = Section.find(params[:id])
    @item.destroy

    redirect_to(admin_sections_url)
  end

  def translation(item, section_translation)
    st = section_translation
    r = get_translation(item, st[:locale])
    r.update_attributes(st)
    r.save(:validate => false)
  end
end
