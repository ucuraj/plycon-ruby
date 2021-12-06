require 'erb'
require 'etc'
require 'date'
require 'time'

##
# Modulo para persistir data localmente.
#
module Polycon
  module Outputs
    class AppointmentGridView
      CURRENT_USER = Etc.getlogin
      PROJECT_BASE_DIR = File.join(Dir.pwd, "lib/polycon")
      USER_HOME = Dir.home(CURRENT_USER)
      PROJECT_DIR_NAME = ".polycon"
      BASE_PATH = File.join(USER_HOME, PROJECT_DIR_NAME)

      DAY_TEMPLATE = File.join(PROJECT_BASE_DIR, "templates/appointments-grid.erb")
      WEEK_TEMPLATE = File.join(PROJECT_BASE_DIR, "templates/appointments-grid-week.erb")

      APPOINTMENTS_RANGES = %w[08:00 08:15 08:30 08:45 09:00 09:15 09:30 09:45 10:00 10:15 10:30 10:45 11:00 11:15 11:30 11:45 12:00 12:15 12:30 12:45 13:00 13:15 13:30 13:45 14:00 14:15 14:30 14:45 15:00 15:15 15:30 15:45]

      def self.output_day_prof(date, professional)
        appointments = APPOINTMENTS_RANGES.map { |x| [x, []] }.to_h
        self.prepare_appointments appointments, professional, date

        title = "Prof #{professional.name} - Appointments Grid (#{date.to_s})"
        self.output("output_day_#{date}", "outputs/#{professional.dir_name}", DAY_TEMPLATE, { appointments_list: appointments, professionals: [professional], day: true, title: title })
      end

      def self.output_day_all(date, professionals)
        appointments = APPOINTMENTS_RANGES.map { |x| [x, []] }.to_h
        professionals.each { |prof| self.prepare_appointments appointments, prof, date }

        title = "Appointments Grid (#{date.to_s})"
        self.output("output_day_#{date.to_s}", "outputs", DAY_TEMPLATE, { appointments_list: appointments, professionals: professionals, day: true, title: title })
      end

      def self.output_week_prof(week_dates, professional)
        # TODO
        appointments = APPOINTMENTS_RANGES.map { |x| [x, []] }.to_h
        week_appointments = []
        self.prepare_week_appointments appointments, professional, week_dates, week_appointments
        puts appointments
        title = "Prof #{professional.name} - Appointments Grid (#{week_dates[0].to_s})"
        self.output("output_week_#{week_dates[0].to_s}", "outputs/#{professional.dir_name}/", WEEK_TEMPLATE, { appointments_list: appointments, professionals: [professional], day: true, title: title })
      end

      def self.output_week_all(week_dates, professionals)
        # TODO
        date = week_dates[0]
        appointments = APPOINTMENTS_RANGES.map { |x| [x, []] }.to_h
        week_appointments = []
        professionals.each { |prof| self.prepare_week_appointments appointments, prof, week_dates, week_appointments }
        title = "Appointments Grid Week (#{week_dates[0]} to #{week_dates[6]})"
        self.output("output_week_#{date}", "outputs", WEEK_TEMPLATE, { appointments_list: appointments, professionals: professionals, day: true, title: title })
      end

      def self.output(name, output_dir, template, **options)
        html = File.open(template).read
        erb = ERB.new(html)
        output = erb.result_with_hash(**options)

        dirname = File.join(BASE_PATH, output_dir)
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
        end
        File.write(File.join(dirname, "#{name}.html"), output)
      end

      def self.prepare_appointments(appointments, professional, date)
        appointments.keys.each do |key|
          begin
            d = Time.parse("#{date} #{key}")
            appointments[key].append(professional.appointment_by_date d)
          rescue Polycon::Models::Appointment::NotFound
            appointments[key].append("")
          end
        end
      end

      def self.prepare_week_appointments(appointments, professional, dates, week)
        dates.each do |date|
          appointments.keys.each do |key|
            begin
              d = Time.parse("#{date} #{key}")
              appointments[key].append(professional.appointment_by_date d)
            rescue Polycon::Models::Appointment::NotFound
              appointments[key].append("")
            end
          end
        end
      end

      def self.output_day(date, args)
        begin
          parsed_date = Time.parse(date.to_s).to_date
          if args[:professional]
            prof = Polycon::Models::Professional.search(args[:professional])
            return self.output_day_prof parsed_date, prof
          end

          professionals = Polycon::Models::Professional.professionals
          if professionals.empty?
            raise Polycon::Models::Professional::NotFound.new("No professionals found")
          end
          self.output_day_all parsed_date, professionals
        rescue Date::Error
          warn "Invalid date. Check format (YYYY-MM-DD)"
        end
      end

      def self.output_week(date, args)
        begin
          parsed_date = Time.parse(date.to_s).to_date
          week_days = (1..7).map do |i|
            Date.commercial(parsed_date.year, parsed_date.cweek.to_i, i)
          end

          if args[:professional]
            prof = Polycon::Models::Professional.search(args[:professional])
            return self.output_week_prof week_days, prof
          end

          professionals = Polycon::Models::Professional.professionals
          if professionals.empty?
            raise Polycon::Models::Professional::NotFound.new("No professionals found")
          end
          self.output_week_all week_days, professionals
        rescue Date::Error
          warn "Invalid date. Check format (YYYY-MM-DD)"
        end
      end

      class FileError < StandardError
        def initialize(msg = "File error")
          super
        end
      end

    end
  end
end