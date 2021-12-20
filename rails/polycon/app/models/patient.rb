class Patient < ApplicationRecord
  has_many :appointments

  def to_s
    "#{self.first_name} #{self.last_name} (#{self.id})"
  end

  def has_appointment(date)
    Appointment.by_patient_date(self.id, date).exists?
  end
end
