class AddProfileToDbUser < ActiveRecord::Migration[7.1]
  def change
    add_column :db_users, :profile, :jsonb, default: {}, null: false
  end
end
