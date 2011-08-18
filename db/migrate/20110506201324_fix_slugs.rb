# -*- encoding : utf-8 -*-
class FixSlugs < ActiveRecord::Migration
  def self.up
    add_index  :articles, :cached_slug, :unique => true
    add_index  :sections, :cached_slug, :unique => true
    add_index  :categories, :cached_slug, :unique => true
    add_index  :users, :cached_slug, :unique => true
  end

  def self.down
    remove_index :articles, :cached_slug
    remove_index :sections, :cached_slug
    remove_index :categories, :cached_slug
    remove_index :users, :cached_slug
  end
end
