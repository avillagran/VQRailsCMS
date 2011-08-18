# -*- encoding : utf-8 -*-
class Category < ActiveRecord::Base
  #make_permalink :with => :title, :prepend_id => true
  has_friendly_id :title, :use_slug => true, :strip_non_ascii => true

  has_many :articles
end
