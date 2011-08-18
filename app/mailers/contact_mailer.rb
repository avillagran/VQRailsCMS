# -*- encoding : utf-8 -*-
class ContactMailer < ActionMailer::Base
  default :from => (defined?(Settings) ? Settings.from_email : nil) || "no-reply@villagranquiroz.cl"

  def contact_email(info)
    @info = info
    puts @info
    mail( :to => (defined?(Settings) ? Settings.contact_email : nil) || "no-reply@villagranquiroz.cl",
          :subject => "Contacto", :cc => @info[:email])
  end
end
