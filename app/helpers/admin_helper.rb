# -*- encoding : utf-8 -*-
module AdminHelper
  def get_categories
    Category.all()
  end
end
