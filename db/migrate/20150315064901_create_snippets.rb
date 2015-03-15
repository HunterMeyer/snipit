class CreateSnippets < ActiveRecord::Migration
  def change
    create_table :snippets do |t|
      t.text :audio_url
      t.text :reference
      t.belongs_to :user
      t.timestamps
    end
  end
end
