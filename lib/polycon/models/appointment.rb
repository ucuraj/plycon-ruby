class Appointment

  def initialize(patient_first_name, patient_last_name, patient_phone, professional, date, observations = "")
    # variables
    @patient_first_name = patient_first_name
    @patient_last_name = patient_last_name
    @patient_phone = patient_phone
    @professional = professional
    @date = date
    @observations = observations
  end

end