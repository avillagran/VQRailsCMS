# -*- encoding : utf-8 -*-
class InitCms < ActiveRecord::Migration
  def self.up
    # SLUGS
    create_table :slugs, :force => true do |t|
      t.string :name
      t.integer :sluggable_id
      t.integer :sequence, :null => false, :default => 1
      t.string :sluggable_type, :limit => 40
      t.string :scope
      t.datetime :created_at
    end
    add_index :slugs, :sluggable_id
    add_index :slugs, [:name, :sluggable_type, :sequence, :scope], :name => "index_slugs_on_n_s_s_and_s", :unique => true

    # USUARIOS
    create_table :users, :force => true do |t|
      t.string  :login
      t.string  :first_name
      t.string  :last_name
      t.string  :state, :default => 'passive'
      t.string  :rut
      t.string  :celphone
      t.string  :phone1
      t.string  :phone2
      t.integer :region_id
      t.integer :commune_id

      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at

      t.string :cached_slug


      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      t.encryptable
      t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable


      t.timestamps
    end

    create_table :roles, :force => true do |t|
      t.string :name
      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true

    # Articles
    create_table :articles, :force => true do |t|
      t.string :title
      t.text :content
      t.string :excerpt
      t.string :status
      t.integer :user_id
      t.integer :parent_id
      t.integer :comments_count
      t.integer :pageviews
      t.integer :twitter_count
      t.integer :facebook_count
      t.integer :section_id
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.string :cached_slug
      t.boolean :highlighted, :default => false
      t.string :template
      t.string :extra

      t.timestamps
    end

    create_table :user_role, :force => true do |t|
      t.integer :user_id
      t.integer :role_id
      t.timestamps
    end

    # ActsAsTaggable
    create_table :tags, :force => true do |t|
      t.string :name
    end

    create_table :taggings, :force => true do |t|
      t.references :tag

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, :polymorphic => true
      t.references :tagger, :polymorphic => true

      t.string :context

      t.datetime :created_at
    end

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]

    # Secciones
    create_table :sections, :force => true do |t|
      t.string  :title
      t.text    :content
      t.integer :order, :default => 0
      t.string  :status, :default => 'hidden'
      t.string  :kind, :default => 'list'
      t.boolean :menu_show_childrens, :default => false
      t.string :template
      t.string :children_template

      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.string :cached_slug

      t.timestamps
    end

    # Assets (Galerías y demases)
    create_table :assets, :force => true do |t|
      t.string :title
      t.text :content
      t.integer :user_id
      t.integer :views, :default => 0

      t.string :asset_file_name
      t.string :asset_content_type
      t.integer :asset_file_size
      t.datetime :asset_updated_at

      t.string :cached_slug

      t.timestamps
    end

    # CATEGORIAS, NO SE USAN ASÍ QUE ESTAN COMENTADAS
=begin
    create_table :categories do |t|
      t.string :title

      t.timestamps
    end
=end

  end

  def self.down
    drop_table :user_role
    drop_table :roles
    drop_table :slugs

    drop_table :users

    drop_table :articles

    drop_table :taggings
    drop_table :tags

    drop_table :sections

    drop_table :assets


    #drop_table :categories
  end
end
