module Polycon
  module Models
    class Professional
      attr_writer :name

      include Polycon::Modules::FileManager

      SAVE_BASE_PATH = ""
      PROFESSIONAL_DATA_FILE_NAME = "data"
      PROFESSIONAL_DATA_FILE_EXT = ".ppf"
      PROFESSIONAL_DATA_FILE = "#{PROFESSIONAL_DATA_FILE_NAME}#{PROFESSIONAL_DATA_FILE_EXT}"

      # initialize method
      def initialize(name, date_joined = Time.now)
        # variables
        if name.strip.empty?
          raise CreateError
        end
        @name = name
        @date_joined = date_joined
      end

      def name
        @name
      end

      def date_joined
        @date_joined
      end

      def dir_name
        Polycon::Helpers::TextHelper.to_snake_case(@name).split.join
      end

      def full_path
        get_abs_path dir_name
      end

      def rel_path
        File.join(SAVE_BASE_PATH, dir_name)
      end

      def save
        if dir_exists?(rel_path)
          if file_exists?(File.join(rel_path, PROFESSIONAL_DATA_FILE))
            raise Exists
          end
        end
        create_dir rel_path
        persist_data(rel_path, PROFESSIONAL_DATA_FILE_NAME, [@name, @date_joined], file_ext: PROFESSIONAL_DATA_FILE_EXT)
      end

      def appointments_list
        list_files(rel_path).select { |file| file.basename.to_s != PROFESSIONAL_DATA_FILE }
      end

      def has_appointments?
        appointments_list.any?
      end

      def appointment(appointment)
        begin
          last_name, first_name, phone, obs = read_file(File.join(rel_path, appointment.filename_ext))
          Polycon::Models::Appointment.new(last_name.to_s, first_name.to_s, phone.to_s, @name, appointment.date, obs.to_s)
        rescue FileManager::FileError
          raise Polycon::Models::Appointment::NotFound
        end
      end

      def cancel_appointment appointment
        begin
          delete_file(rel_path, appointment.filename_ext)
          puts "Appointment cancelled"
        rescue => e
          warn "Error cancelling appointment"
        end
      end

      def cancel_all_appointments
        if has_appointments?
          begin
            appointments_list.map { |ap| delete_file(rel_path, ap.basename) }
            return warn "All appointments were deleted"
          rescue => e
            warn "Error cancelling appointment"
            return
          end
        end
        warn "Professional #{@name} has no appointments"
      end

      def print_appointments(appointments)
        appointments.each_with_index.map do |ap_file, i|
          date = Polycon::Models::Appointment.format_str_date(ap_file)
          ap = appointment Polycon::Models::Appointment.new("", "", "", @name, date)
          puts "#{i + 1}. #{appointment(ap)}"
        end
      end

      def list_all_appointments
        print_appointments appointments_list
      end

      def list_appointments_by_date(date)
        begin
          ap_filtered = appointments_list.select { |ap_file| date.eql? Date.parse(ap_file.basename.to_s.split("_")[0]) }
          ap_filtered.any? ? (print_appointments ap_filtered) : (puts "No appointments found")
        rescue Date::Error
          warn "Invalid date. Check format (YYYY-MM-DD)"
        end
      end

      def list_appointments(date = nil)
        puts "\nAPPOINTMENTS OF #{@name}\n\n"
        puts Polycon::Helpers::TextHelper.bar
        begin
          if has_appointments?
            date ? list_appointments_by_date(date) : list_all_appointments
          else
            puts "No appointments found"
          end
          puts "#{Polycon::Helpers::TextHelper.bar}\n\n"
        rescue Polycon::Models::Appointment::CreateError => e
          return warn "Cannot retrieve appointments."
        end
      end

      def find_appointment(date, raise_exception = false)
        begin
          ap_to_search = appointment Polycon::Models::Appointment.new("", "", "", @name, date)
          return appointments_list.select { |ap_file| ap_file.basename.to_s.eql? ap_to_search.filename_ext }[0]
        rescue Polycon::Models::Appointment::NotFound => e
          raise_exception ? (raise e) : (nil)
        end
      end

      def rename_appointment(old_file, new_filename)
        begin
          rename_file old_file, new_filename, true
          puts "Appointment successfully rescheduled."
        rescue Errno::ENOENT, FileManager::FileNotFound => e
          warn "Can not rename appointment"
        end
      end

      def reschedule(old_date, new_date)
        begin
          old_appointment = find_appointment(old_date, true)
          new_appointment = find_appointment(new_date)
        rescue Polycon::Models::Appointment::NotFound => e
          return warn e
        end

        if new_appointment
          return warn "Found appointment with date #{new_date.to_s}. Select another date to reschedule appointment"
        end
        new_filename = Pathname.new(old_appointment.dirname).join Polycon::Models::Appointment.new("", "", "", @name, new_date).filename_ext
        rename_appointment old_appointment, new_filename
      end

      def edit_appointment(date, **args)
        begin
          appoint = appointment Polycon::Models::Appointment.new("", "", "", @name, date)
          appoint.edit(args)
          appoint.save(true)
        rescue Polycon::Models::Appointment::NotFound => e
          return warn e
        end
      end

      def to_s
        super
        "#{@name} - Registrado el #{@date_joined.to_s}"
      end

      ##
      # Class Methods
      #

      def self.professionals_list
        list_dirs(SAVE_BASE_PATH).select { |prof| file_exists? File.join(prof.basename, PROFESSIONAL_DATA_FILE) }
      end

      def self.list
        professionals = self.professionals_list
        puts "\n PROFESSIONAL LIST\n\n"
        puts Polycon::Helpers::TextHelper.bar

        if professionals.any?
          puts professionals.each_with_index.map { |p, i| "#{i + 1}. #{Polycon::Helpers::TextHelper.snake_to_spaced(p.basename.to_s)}" }
        else
          puts "No professionals available"
        end

        return puts "#{Polycon::Helpers::TextHelper.bar}\n\n"
      end

      private :appointments_list

      def self.search(name)
        prof_dir = Polycon::Helpers::TextHelper.to_snake_case(name).split.join
        prof_file = File.join(SAVE_BASE_PATH, prof_dir, PROFESSIONAL_DATA_FILE)

        result = self.professionals_list.select { |prof| prof.basename.to_s == prof_dir }
        begin
          if result.any?
            begin
              prof_name, prof_date_joined = read_file(prof_file)
              return Professional.new(prof_name.to_s, prof_date_joined.to_s)
            end
          end
        rescue FileManager::FileError
          raise NotFound
        end
      end

      def self.delete(name)
        begin
          professional = self.search(name)
          if professional.has_appointments?
            return warn "#{professional.name} has appointments. Cannot be deleted"
          end

          print "Please confirm the deletion of the professional #{professional.name} (y/n): "
          confirm = STDIN.gets.chomp
          if confirm != "y"
            return warn "Canceled."
          end

          begin
            delete_dir(professional.dir_name)
          rescue FileManager::DirNotFound
            warn "Can not delete professional."
          end
          puts "Professional #{professional.name} has been deleted."
        rescue NotFound => e
          warn e
        end
      end

      def self.rename(professional_name, new_name)
        begin
          professional = self.search(professional_name)
        rescue NotFound => e
          return warn e
        end

        prof_file = File.join(professional.dir_name, PROFESSIONAL_DATA_FILE)
        _, prof_date_joined = read_file(prof_file)

        if professional.has_appointments?
          return warn "#{professional.name} has appointments. Cannot be rename TODO"
        end

        begin
          old_path = professional.rel_path
          professional.name = new_name

          rename_dir(old_path, professional.rel_path)

          data = [new_name, prof_date_joined]
          persist_data(professional.rel_path, PROFESSIONAL_DATA_FILE_NAME, data, file_ext: PROFESSIONAL_DATA_FILE_EXT)
        rescue => e
          warn e
          warn "Error trying to rename #{professional_name} to #{new_name}"
        end
      end

      def self.reschedule(old_date, new_date, professional)
        begin
          prof = self.search professional
          prof.has_appointments? ? (prof.reschedule(old_date, new_date)) : (warn "The professional #{prof.name} does not have appointments")
        rescue Professional::NotFound, Polycon::Models::Appointment::NotFound => e
          warn e
        end
      end

      def self.edit_appointment(date, professional, **args)
        begin
          prof = self.search professional
          prof.has_appointments? ? (prof.edit_appointment(date, args)) : (warn "The professional #{prof.name} does not have appointments")
        rescue Professional::NotFound, Polycon::Models::Appointment::NotFound => e
          warn e
        rescue Date::Error
          warn "Invalid date. Check format (YYYY-MM-DD)"
        end
      end

      ##
      # Exceptions
      #
      class Exists < StandardError
        def initialize(msg = "The professional is already registered in Polycon")
          super
        end
      end

      class NotFound < StandardError
        def initialize(msg = "The professional is not registered in Polycon")
          super
        end
      end

      class CreateError < StandardError
        def initialize(msg = "Error creating professional, field 'name' cannot be blank")
          super
        end
      end
    end
  end
end

