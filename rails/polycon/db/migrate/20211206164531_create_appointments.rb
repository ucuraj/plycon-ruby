class CreateAppointments < ActiveRecord::Migration[6.1]
  def change
    create_table :appointments do |t|
      t.string :observations
      t.datetime :date
      t.belongs_to :patient, null: false, foreign_key: true
      t.belongs_to :professional, null: false, foreign_key: true

      t.timestamps
    end
  end
end
