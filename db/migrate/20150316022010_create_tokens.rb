class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :access_token
      t.string :user_id
      t.datetime :expiration_date

      t.timestamps
    end
  end
end
