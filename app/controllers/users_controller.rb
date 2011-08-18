# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  def update
    @item = User.find(params[:id])

    if params.has_key?(:user)
      @item.update_attributes(params[:user])
    end
    redirect_back_or_default
  end
end
