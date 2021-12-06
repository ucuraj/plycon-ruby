class CreateAppointments < ActiveRecord::Migration[6.1]
  def change
    create_table :appointments do |t|
      t.belongs_to :professional
      t.belongs_to :patient

      t.datetime :date
      t.string :observations
      t.timestamps
    end
  end
end
