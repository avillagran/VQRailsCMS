# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base

  #has_friendly_id :first_name :use_slug => true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         #, :confirmable,

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me,
  #                :first_name, :last_name, :rut, :state, :celphone, :phone1, :phone2, :avatar

  has_many :articles

  has_attached_file :avatar,
                    :styles => {  :small => '50x50#',
                                  :medium => "300x300>",
                                  :thumb => "100x100>" }

  def full_name
    return self.email if self.first_name.blank? and self.last_name.blank?

    return "#{self.first_name} #{self.last_name}"
  end
end
