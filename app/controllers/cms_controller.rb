# -*- encoding : utf-8 -*-
class CmsController < ApplicationController

  def contact
    ContactMailer.contact_email(params[:contact]).deliver
    flash[:notice] = "Gracias por contactarnos, nos pondremos a la brevedad en contacto"
    redirect_to root_path
  end

end
