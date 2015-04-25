class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.integer :user_id
      t.string :access_token
      t.datetime :expiration_date

      t.timestamps
    end
  end
end
