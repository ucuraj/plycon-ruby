module Polycon
  module Commands
    module Appointments
      class Create < Dry::CLI::Command
        desc 'Create an appointment'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: true, desc: 'Full name of the professional'
        option :name, required: true, desc: "Patient's name"
        option :surname, required: true, desc: "Patient's surname"
        option :phone, required: true, desc: "Patient's phone number"
        option :notes, required: false, desc: "Additional notes for appointment"

        example [
                  '"2021-09-16 13:00" --professional="Alma Estevez" --name=Carlos --surname=Carlosi --phone=2213334567'
                ]

        def call(date:, professional:, name:, surname:, phone:, notes: nil)
          begin
            Polycon::Models::Appointment.new(name, surname, phone, professional, date, notes).save
          rescue Polycon::Models::Appointment::CreateError => e
            warn e.data
          end
        end
      end

      class Show < Dry::CLI::Command
        desc 'Show details for an appointment'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: true, desc: 'Full name of the professional'

        example [
                  '"2021-09-16 13:00" --professional="Alma Estevez" # Shows information for the appointment with Alma Estevez on the specified date and time'
                ]

        def call(date:, professional:)
          Polycon::Models::Appointment.show(date, professional)
        end
      end

      class Cancel < Dry::CLI::Command
        desc 'Cancel an appointment'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: true, desc: 'Full name of the professional'

        example [
                  '"2021-09-16 13:00" --professional="Alma Estevez" # Cancels the appointment with Alma Estevez on the specified date and time'
                ]

        def call(date:, professional:)
          Polycon::Models::Appointment.cancel(date, professional)
        end
      end

      class CancelAll < Dry::CLI::Command
        desc 'Cancel all appointments for a professional'

        argument :professional, required: true, desc: 'Full name of the professional'

        example [
                  '"Alma Estevez" # Cancels all appointments for professional Alma Estevez',
                ]

        def call(professional:)
          Polycon::Models::Appointment.cancel_all(professional)
        end
      end

      class List < Dry::CLI::Command
        desc 'List appointments for a professional, optionally filtered by a date'

        argument :professional, required: true, desc: 'Full name of the professional'
        option :date, required: false, desc: 'Date to filter appointments by (should be the day)'

        example [
                  '"Alma Estevez" # Lists all appointments for Alma Estevez',
                  '"Alma Estevez" --date="2021-09-16" # Lists appointments for Alma Estevez on the specified date'
                ]

        def call(professional:, **options)
          Polycon::Models::Appointment.list_appointments(professional, **options)
        end
      end

      class Reschedule < Dry::CLI::Command
        desc 'Reschedule an appointment'

        argument :old_date, required: true, desc: 'Current date of the appointment'
        argument :new_date, required: true, desc: 'New date for the appointment'
        option :professional, required: true, desc: 'Full name of the professional'

        example [
                  '"2021-09-16 13:00" "2021-09-16 14:00" --professional="Alma Estevez" # Reschedules appointment on the first date for professional Alma Estevez to be now on the second date provided'
                ]

        def call(old_date:, new_date:, professional:)
          Polycon::Models::Professional.reschedule(old_date, new_date, professional)
        end
      end

      class Edit < Dry::CLI::Command
        desc 'Edit information for an appointments'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: true, desc: 'Full name of the professional'
        option :name, required: false, desc: "Patient's name"
        option :surname, required: false, desc: "Patient's surname"
        option :phone, required: false, desc: "Patient's phone number"
        option :notes, required: false, desc: "Additional notes for appointment"

        example [
                  '"2021-09-16 13:00" --professional="Alma Estevez" --name="New name" # Only changes the patient\'s name for the specified appointment. The rest of the information remains unchanged.',
                  '"2021-09-16 13:00" --professional="Alma Estevez" --name="New name" --surname="New surname" # Changes the patient\'s name and surname for the specified appointment. The rest of the information remains unchanged.',
                  '"2021-09-16 13:00" --professional="Alma Estevez" --notes="Some notes for the appointment" # Only changes the notes for the specified appointment. The rest of the information remains unchanged.',
                ]

        def call(date:, professional:, **options)
          begin
            Polycon::Models::Professional.edit_appointment(date, professional, options)
          rescue Polycon::Models::Appointment::InvalidMinuteError, Polycon::Models::Appointment::InvalidHourError => e
            warn e
          end
        end
      end

      class ExportDay < Dry::CLI::Command
        desc 'Export grid of appointments(day) for a date. optionally filtered by a professional'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: false, desc: 'Full name of the professional'

        example [
                  '--date "2021-09-16 13:00" --professional="Alma Estevez"',
                ]

        def call(date:, **options)
          begin
            Polycon::Outputs::AppointmentGridView.output_day(date, options)
          rescue Polycon::Models::Professional::NotFound => e
            warn e
          end
        end
      end

      class ExportWeek < Dry::CLI::Command
        desc 'Export grid of appointments(week) for a date. optionally filtered by a professional'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: false, desc: 'Full name of the professional'

        example [
                  '--date "2021-09-16 13:00" --professional="Alma Estevez"',
                ]

        def call(date:, **options)
          begin
            Polycon::Outputs::AppointmentGridView.output_week(date, options)
          rescue Polycon::Models::Professional::NotFound => e
            warn e
          end
        end
      end
    end
  end
end
