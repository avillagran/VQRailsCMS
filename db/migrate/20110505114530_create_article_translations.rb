# -*- encoding : utf-8 -*-
class CreateArticleTranslations < ActiveRecord::Migration
  def self.up 
    create_table(:article_translations) do |t|
      t.references :article
      t.string :locale

      t.string :title
      t.text :content
      t.string :extra

      t.timestamps
    end
    add_index :article_translations, [:article_id, :locale], :unique => true
  end

  def self.down
    drop_table :article_translations
  end
end

