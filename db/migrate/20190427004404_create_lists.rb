class CreateLists < ActiveRecord::Migration[5.2]
  def change
    create_table :lists do |t|
    	t.string :name, null: false #リスト名
    	t.integer :switch, null: false #onoff
    	t.datetime :c_at, null: true #チェックした日付

    	# userモデルのuser_idに結びつけるため、必要
        t.integer :user_id, null: true
      t.timestamps
    end
  end
end
