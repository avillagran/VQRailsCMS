# -*- encoding : utf-8 -*-
class CreateSectionTranslations < ActiveRecord::Migration
  def self.up 
    create_table(:section_translations) do |t|
      t.references :section
      t.string :locale

      t.string :title
      t.text :content

      t.timestamps
    end
    add_index :section_translations, [:section_id, :locale], :unique => true
  end

  def self.down
    drop_table :section_translations
  end
end

