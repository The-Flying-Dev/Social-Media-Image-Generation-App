class AddHtmlToArticles < ActiveRecord::Migration[5.1]
  def change
    add_column :articles, :html, :text
  end
end
