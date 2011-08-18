# -*- encoding : utf-8 -*-
class Admin::AdminController < ApplicationController
  layout 'admin'
 
	uses_tiny_mce :options => {
                            :theme => 'advanced',
                            :theme_advanced_resizing => true,
        					:theme_advanced_buttons3_add => "tablecontrols",
							:table_styles => "Header 1=header1;Header 2=header2;Header 3=header3",
        					:table_cell_styles => "Header 1=header1;Header 2=header2;Header 3=header3;Table Cell=tableCel1",
        					:table_row_styles => "Header 1=header1;Header 2=header2;Header 3=header3;Table Row=tableRow1",
        					:table_cell_limit => 100,
        					:table_row_limit => 5,
        					:table_col_limit => 5,        
               		        :theme_advanced_resize_horizontal => false,
                            :plugins => %w{ table fullscreen }
                          }
  before_filter :check_permissions, :admin_init
  helper_method :nav_menu, :get_translation, :admin_login
     
     
        
  def admin_init
    session.delete(:lang)
    I18n.locale = I18n.default_locale
  end

  def check_permissions
    # Falta la verificación de permisos
    if defined?(admin_login) && !admin_login
      render "admin/login"
    end
  end

  def nav_menu(name, path, opts={})
    opts[:active_word] = "active" unless opts.has_key?(:active_word)

    inf = Rails.application.routes.recognize_path(path, :method => :get)

    cls = ""

    cls  = " class=\"#{opts[:active_word]}\"" if params[:controller] == inf[:controller]


    "<li#{cls}><a href=\"#{path}\">#{name}</a></li>"
  end

  protected

  def admin_login
    #session[:admin_logged] = false
    return true if params.has_key?("qqfile")

    if session.has_key?(:admin_logged) && session[:admin_logged] == true
      return true
    else
      session[:admin_logged] = false

      has_settings = defined?(Settings) && Settings.admin
      cms_admin = has_settings ? Settings.admin.user : 'admin'
      cms_pass  = has_settings ? Settings.admin.password : 'owadmin'

      if params.has_key?(:user_login)
        session[:admin_logged] = true if params[:user_login][:login] == cms_admin && params[:user_login][:password] == cms_pass
      end

      return session[:admin_logged]
    end

  end
end
