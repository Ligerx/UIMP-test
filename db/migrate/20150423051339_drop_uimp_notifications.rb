class DropUimpNotifications < ActiveRecord::Migration
  def change
    drop_table :uimp_notifications
  end
end
