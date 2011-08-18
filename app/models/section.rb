# -*- encoding : utf-8 -*-
class Section < CmsModel
  include Pacecar

  acts_as_nested_set

  has_friendly_id :title, :use_slug => true, :strip_non_ascii => true

  #make_permalink :with => :title, :prepend_id => false, :escape => true

  STATES   = %w{hidden visible}
  KINDS    = %w{list page}

  has_state :state, :with => STATES
  has_state :kind,  :with => KINDS

  has_many :articles

  has_attached_file :image, :styles => { :thumb => "100x100#" }


  def Section.states
    get_states(STATES)
  end

  def Section.kinds
    get_states(KINDS)
  end

end
