class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.string :url #added column before migration
      t.timestamps
    end
  end
end
