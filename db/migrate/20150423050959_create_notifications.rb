class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.string :event
      t.string :medium_type
      t.string :medium_information

      t.timestamps
    end
  end
end
