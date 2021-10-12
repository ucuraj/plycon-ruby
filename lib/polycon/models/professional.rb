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
        last_name, first_name, phone, obs = read_file(File.join(rel_path, appointment.filename_ext), true, exception = Polycon::Models::Appointment::NotFound)
        Polycon::Models::Appointment.new(last_name.to_s, first_name.to_s, phone.to_s, @name, appointment.date, obs.to_s)
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

      def self.search(name)
        prof_dir = Polycon::Helpers::TextHelper.to_snake_case(name).split.join
        prof_file = File.join(SAVE_BASE_PATH, prof_dir, PROFESSIONAL_DATA_FILE)

        result = self.professionals_list.select { |prof| prof.basename.to_s == prof_dir }
        if result.any?
          begin
            prof_name, prof_date_joined = read_file(prof_file, true, NotFound)
            return Professional.new(prof_name.to_s, prof_date_joined.to_s)
          end
        end
        raise NotFound
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

          delete_dir(professional.dir_name)
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
        _, prof_date_joined = read_file(prof_file, raise_exception = true, exception = Errno::ENOENT)

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
    end
  end
end