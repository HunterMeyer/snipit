class AddFromToSnippets < ActiveRecord::Migration
  def change
    add_column :snippets, :from, :text
  end
end
