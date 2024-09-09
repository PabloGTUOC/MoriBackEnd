class CreateTrainings < ActiveRecord::Migration[7.1]
  def change
    create_table :trainings do |t|
      t.integer :user_id
      t.date :date
      t.float :weight

      t.timestamps
    end
  end
end
