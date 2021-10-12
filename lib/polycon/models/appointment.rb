module Polycon
  module Models
    class Appointment
      include Polycon::Modules::FileManager

      PROFESSIONAL_DATA_FILE_EXT = ".paf"

      attr_accessor :patient_first_name, :patient_last_name, :patient_phone, :professional, :date, :observations

      def initialize(patient_first_name, patient_last_name, patient_phone, professional_name, date, observations = "")
        # variables
        begin
        @patient_first_name = patient_first_name
        @patient_last_name = patient_last_name
        @patient_phone = patient_phone
        @professional = Polycon::Models::Professional.search(professional_name)
        @date = date
        @observations = observations
        rescue Polycon::Models::Professional::NotFound => e
          warn "Cannot create Appointment. #{e}"
        end
      end
    end
  end
end