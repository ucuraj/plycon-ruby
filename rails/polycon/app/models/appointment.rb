class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :professional

  VALID_MINUTES = [0, 15, 30, 45]
  HOURS_RANGE = (8..15).to_a

  def to_s
    "#{self.date.to_s} - #{self.patient.to_s}"
  end

  validate :validate_date
  validate :validate_patient

  scope :by_patient_date, lambda { |patient_id, date|
    Appointment.joins(:patient).where(patients: { id: patient_id }, date: date).distinct
  }

  private

  def convert_date
    begin
      d = Time.parse(self.date.to_s).to_time
      unless VALID_MINUTES.include? d.min
        raise InvalidMinuteError
      end
      unless HOURS_RANGE.include? d.hour
        raise InvalidHourError
      end
      return true
    rescue ArgumentError, InvalidHourError, InvalidMinuteError
      false
    end
  end

  def validate_date
    errors.add("Appointment Date", "is invalid. Date hours must be between #{HOURS_RANGE} and minutes must be between 00, 15, 30, 45") unless convert_date
  end

  def validate_patient
    has_appointment = self.patient.has_appointment(self.date)
    errors.add("The patient", "#{self.patient} already has an appointment registered for the date and time received") if has_appointment
  end

  def self.delete_by_professional professional_id
    Appointment.where(professional_id: professional_id).destroy_all
  end

  ##
  # Exceptions
  #
  class InvalidHourError < StandardError
  end

  class InvalidMinuteError < StandardError
  end
end
