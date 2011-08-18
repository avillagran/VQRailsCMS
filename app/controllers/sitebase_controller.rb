# -*- encoding : utf-8 -*-
class SitebaseController < ApplicationController
  before_filter :sb_init

  def sb_init
    SimpleForm.wrapper_class  = "group"
  end
  def es
    I18n.locale = :es
    session[:lang] = I18n.locale

    redirect_back_or_default '/'
  end

  def en
    I18n.locale = :en
    session[:lang] = I18n.locale
    redirect_back_or_default '/'
  end
end
