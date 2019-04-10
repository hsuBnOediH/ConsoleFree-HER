class CreateRepos < ActiveRecord::Migration[5.1]
  def change
    create_table :repos do |t|
      t.string :repo_name
      t.integer :seed_size
      t.string :language
      t.string :entities
      t.string :sort_method
      t.string :status

      t.timestamps
    end
  end
end
