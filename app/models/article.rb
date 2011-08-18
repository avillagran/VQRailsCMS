# -*- encoding : utf-8 -*-
class Article < CmsModel
  include Pacecar
  puret :title, :content

  acts_as_taggable_on :tags, :categories

  acts_as_commentable

  #make_permalink :with => :title, :field => 'title', :prepend_id => false, :escape => true, :forbidden => %w{new edit}
  has_friendly_id :title, :use_slug => true, :strip_non_ascii => true

  default_scope :order => 'created_at DESC'
  validates_presence_of :title, :message => "Debes incluir un título"

  belongs_to :user
  belongs_to :section
  belongs_to :category

  has_and_belongs_to_many :articles, :foreign_key => "parent_id"

  has_attached_file :image, :styles => { :thumb => "100x100#" }

  STATES   = %w{draft published}

  has_state :status, :with => STATES

  def Article.states
    get_states(STATES)
  end

  def get_link
    section = self.section

    tree = []
    str = ''
    tree << section.to_param
    while !section.root?
      section = section.parent
      tree << section.to_param
    end
    tree = tree.reverse
    tree.each do |i|
      str << "/#{i}"
    end
    return "#{str}/#{self.to_param}"
  end

end
