# -*- encoding : utf-8 -*-
class PanelController < ApplicationController
  before_filter :store_location, :only => [:avatar]

  def index

  end

  def update
    current_user.update_attributes(params[:user])

    redirect_to panel_path
  end

  def avatar
    @item = current_user
  end

end
