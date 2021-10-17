require "time"

module Polycon
  module Models
    class Appointment
      include Polycon::Modules::FileManager

      APPOINTMENT_DATA_FILE_EXT = ".paf"
      DEFAULT_STRFTIME = "%Y-%m-%d_%H-%M"

      attr_accessor :patient_first_name, :patient_last_name, :patient_phone, :professional, :date, :observations

      def initialize(patient_first_name, patient_last_name, patient_phone, professional_name, date, observations = "")
        # variables
        begin
          @patient_first_name = patient_first_name
          @patient_last_name = patient_last_name
          @patient_phone = patient_phone
          @professional = Polycon::Models::Professional.search(professional_name)
          @date = Time.parse(date.to_s).to_time
          @observations = observations
        rescue Polycon::Models::Professional::NotFound => e
          raise CreateError.new(extra: "Professional #{professional_name} not found")
        rescue ArgumentError => e
          raise CreateError.new(extra: "Invalid date")
        end
      end

      def filename_ext
        "#{filename}#{APPOINTMENT_DATA_FILE_EXT}"
      end

      def filename
        @date.strftime(DEFAULT_STRFTIME)
      end

      def edit(**args)
        args[:name] && (@patient_first_name = args[:name])
        args[:surname] && (@patient_last_name = args[:surname])
        args[:notes] && (@observations = args[:notes])
      end

      def save(edit = false)
        data = [@patient_last_name, @patient_first_name, @patient_phone, @observations]
        path = @professional.rel_path

        if edit
          if path_file_exists?(path, filename_ext)
            persist_data(path, filename, data)
            return puts "Appointment updated"
          else
            raise NotFound
          end
        end

        if path_file_exists?(path, filename_ext)
          raise CreateError.new(extra: "There is already an appointment for the professional #{professional.name} with date #{@date}")
        end
        persist_data(path, filename, data)
        puts "Appointment saved"
      end

      def show
        puts Polycon::Helpers::TextHelper.bar
        puts "Appointment Data"
        puts Polycon::Helpers::TextHelper.bar
        puts "Professional: #{@professional.name}"
        puts "Date: #{@date}"
        puts "Patient name: #{patient_last_name}, #{patient_first_name}"
        puts "Patient phone: #{@patient_phone}"
        puts "*Obs: #{@observations}"
        puts Polycon::Helpers::TextHelper.bar
      end

      def cancel
        print "Please confirm cancellation (y/n): "
        confirm = STDIN.gets.chomp
        if confirm != "y"
          return warn "Aborted."
        end
        @professional.cancel_appointment self
      end

      def to_s
        "#{@date} - #{@patient_first_name} #{@patient_last_name}"
      end

      ##
      # Class Methods
      #

      def self.search(date, professional)
        begin
          prof = Polycon::Models::Professional.search(professional)
          prof.appointment Appointment.new("", "", "", prof.name, date)
        rescue Polycon::Models::Professional::NotFound => e
          warn e.to_s
          raise NotFound
        rescue CreateError => e
          warn "Date no valid."
          raise NotFound
        rescue NotFound => e
          raise NotFound
        end
      end

      def self.show(date, professional)
        begin
          appointment = search(date, professional)
          appointment.show
        rescue NotFound => e
          warn e
        end
      end

      def self.cancel(date, professional)
        begin
          appointment = search(date, professional)
          appointment.cancel
        rescue NotFound => e
          warn e
        end
      end

      def self.cancel_all(professional)
        begin
          prof = Polycon::Models::Professional.search(professional)

          print "Please confirm cancellation of all appointments (y/n): "
          confirm = STDIN.gets.chomp
          if confirm != "y"
            return warn "Aborted."
          end

          prof.cancel_all_appointments
        rescue Polycon::Models::Professional::NotFound => e
          warn e.to_s
        end
      end

      def self.list_appointments(professional, **args)
        begin
          prof = Polycon::Models::Professional.search(professional)
          date = Date.parse args[:date] if args[:date]
          prof.list_appointments(date)
        rescue Polycon::Models::Professional::NotFound => e
          warn e.to_s
        rescue Date::Error
          warn "Invalid date. Check format (YYYY-MM-DD)"
        end
      end

      def self.format_str_date(ap_file, split = "_", join = " ")
        date = File.basename(ap_file, ap_file.extname).split(split).join(join)
        date[-3] = ":"
        date
      end

      ##
      # Exceptions
      #
      class CreateError < StandardError
        attr_reader :data

        def initialize(data)
          super
          @data = "Cannot create Appointment. #{data[:extra]}"
        end

        def to_s
          @data
        end
      end

      class NotFound < StandardError
        def initialize(msg = "Appointment not found in Polycon")
          super
        end
      end
    end
  end
end