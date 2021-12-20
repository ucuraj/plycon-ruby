class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :professional

  VALID_MINUTES = [0, 15, 30, 45]
  HOURS_RANGE = (8..15).to_a
  APPOINTMENTS_RANGES = %w[08:00 08:15 08:30 08:45 09:00 09:15 09:30 09:45 10:00 10:15 10:30 10:45 11:00 11:15 11:30 11:45 12:00 12:15 12:30 12:45 13:00 13:15 13:30 13:45 14:00 14:15 14:30 14:45 15:00 15:15 15:30 15:45]

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
    errors.add("Appointment Date", "is invalid. Date hours must be between 8-15 hours and minutes must be between 00, 15, 30, 45") unless convert_date
  end

  def validate_patient
    if self.patient
      has_appointment = self.patient.has_appointment(self.date)
      errors.add("The patient", "#{self.patient} already has an appointment registered for the date and time received") if has_appointment
    else
      errors.add("You must select a patient", "")
    end
  end

  def self.delete_by_professional professional_id
    Appointment.where(professional_id: professional_id).destroy_all
  end

  ##
  #
  def self.get_day_appointments(date = Date.today, professional_id = nil)
    appointments = APPOINTMENTS_RANGES.map { |x| [x, []] }.to_h

    appointments.keys.each do |key|
      begin
        d = Time.parse("#{date} #{key}")
        app = self.get_appointment_by_date d, professional_id
        if app.nil?
          app = ""
        end
        appointments[key].append(app)
      end
    end
    return appointments
  end

  def self.get_week_appointments
    self.get_appointments_by_week DateTime.now
  end

  def self.get_appointments_by_day(day)
    Appointment.where(date: (day.change({ hour: 8, min: 00 }))..day.change({ hour: 16, min: 00 }))
  end

  def self.get_appointment_by_date(date, professional_id)
    if professional_id and professional_id != ""
      return Appointment.where(date: date, professional_id: professional_id).first
    end
    Appointment.where(date: date).first
  end

  def self.get_appointments_by_week(day)
    week_days = (1..7).map do |i|
      Date.commercial(day.year, day.cweek.to_i, i)
    end
    first_week_day = week_days[0]
    last_week_day = week_days[-1]
    Appointment.where(date: (first_week_day.change({ hour: 8, min: 00 }))..last_week_day.change({ hour: 16, min: 00 }))
  end

  def self.get_day_appointments_by_prof(professional, day = DateTime.now)
    appointments = self.get_appointments_by_day day
    appointments.select { |app| app.professional = professional }
  end

  def self.get_week_appointments_by_prof(professional, day = DateTime.now)
    appointments = self.get_appointments_by_week day
    appointments.select { |app| app.professional = professional }
  end

  ##
  # Exceptions
  #
  class InvalidHourError < StandardError
  end

  class InvalidMinuteError < StandardError
  end
end
