class AddDreamToDbUser < ActiveRecord::Migration[7.1]
  def change
    add_column :db_users, :dream, :jsonb, default: {}, null: false
  end
end
