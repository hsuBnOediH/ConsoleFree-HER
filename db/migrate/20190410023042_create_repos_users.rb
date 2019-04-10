class CreateReposUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :repos_users do |t|
      t.references :users, foreign_key: true
      t.references :repo, foreign_key: true

      t.timestamps
    end
  end
end
