# -*- encoding : utf-8 -*-
Rails.application.routes.draw do
  # Administrador
  namespace :admin do
    resources :articles
    match "articles/:id/update" => "articles#update", :as => :update_article
    match "articles/:section_id/section" => "articles#section", :as => :section_articles

    resources :dashboard
    resources :configs
    resources :sections
    match "sections/:id/update" => "sections#update", :as => :update_section
    match "sections/:section_id/translation" => "sections#translation", :as => :section_translation
    match "articles/:article_id/translation" => "articles#translation", :as => :article_translation
    resources :users

    # Solo mantenedores REST-JSON
    resources :categories
    # Fin mantenedores

    root :to => "dashboard#index"
  end

  match "es" => "site#es"
  match "en" => "site#en"

  # Panel para los usuarios
  match "panel/update" => "panel#update"
  resources :panel

  match "search" => "search#index"
  # Comentarios
  match "articles/add_comment" => "articles#add_comment"
  # Controlador articles_controller
  resources :articles



  # Configurando para que no puedan acceder directamente a los temas
  #match "themes/*a/controllers/*b" => "site#notfound"
  #match "themes/*a/templates/*b" => "site#notfound"
  #
  # Secciones
  resources :sections

  # Para usuarios con Devise
  devise_for   :users,
               :path => "",
               :path_names => {   :sign_in => 'login',
                                  :sign_out => 'logout',
                                  :password => 'secret',
                                  :confirmation => 'verification',
                                  :unlock => 'unblock',
                                  :registration => 'register',
                                  :sign_up => ''
                              }

  # Vistas de usuarios
  resources :users

  # Mailer
  match "contact/send" => "cms#contact", :as => "send_contact"


  # Esto es para las secciones -> artículos
  match ":id" => "sections#show", :as => :seccion

  match "*section/:id", :controller => :articles, :action => :show, :format => :html,
                        :constraints =>
                        {
                          :id => /[a-zA-Z0-9ñáéíóúàèìòùÁÉÍÓÚÀÈÌÒÙ'’´%E2%80%99\-]+/#,
                          #:section => /^(?!system).+/
                        }



end
