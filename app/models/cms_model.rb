# -*- encoding : utf-8 -*-
class CmsModel < ActiveRecord::Base
  self.abstract_class = true

  def CmsModel.get_states(var)
    hs = {}
    var.each do |i|
      hs[i.capitalize] = i
    end
    return hs
  end
end
