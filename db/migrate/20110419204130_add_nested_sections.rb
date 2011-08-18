# -*- encoding : utf-8 -*-
class AddNestedSections < ActiveRecord::Migration
  def self.up
    add_column :sections, :parent_id, :integer
    add_column :sections, :lft, :integer
    add_column :sections, :rgt, :integer
    add_column :sections, :image_file_name, :string
    add_column :sections, :image_content_type, :string
    add_column :sections, :image_file_size, :integer
    add_column :sections, :image_updated_at, :datetime
  end

  def self.down
    remove_column :sections, :rgt
    remove_column :sections, :lft
    remove_column :sections, :parent_id
    remove_column :sections, :image_file_name
    remove_column :sections, :image_content_type
    remove_column :sections, :image_file_size
    remove_column :sections, :image_updated_at
  end
end
