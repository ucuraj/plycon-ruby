require 'erb'
require 'etc'
require 'date'
require 'time'

class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  APPOINTMENTS_RANGES = %w[08:00 08:15 08:30 08:45 09:00 09:15 09:30 09:45 10:00 10:15 10:30 10:45 11:00 11:15 11:30 11:45 12:00 12:15 12:30 12:45 13:00 13:15 13:30 13:45 14:00 14:15 14:30 14:45 15:00 15:15 15:30 15:45]

  # GET /appointments or /appointments.json
  def index
    @appointments = Appointment.all
  end

  # GET /appointments/1 or /appointments/1.json
  def show
  end

  # GET /appointments/new
  def new
  end

  # GET /appointments/1/edit
  def edit
  end

  # POST /appointments or /appointments.json
  def create

    respond_to do |format|
      if @appointment.save
        format.html { redirect_to @appointment, notice: "Appointment was successfully created." }
        format.json { render :show, status: :created, location: @appointment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appointments/1 or /appointments/1.json
  def update
    respond_to do |format|
      if @appointment.update(appointment_params)
        format.html { redirect_to @appointment, notice: "Appointment was successfully updated." }
        format.json { render :show, status: :ok, location: @appointment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointments/1 or /appointments/1.json
  def destroy
    @appointment.destroy
    respond_to do |format|
      format.html { redirect_to appointments_url, notice: "Appointment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /appointments/export_day or /appointments/export_day.json
  def export_day
  end

  # GET /appointments/export_day or /appointments/export_day.json
  def export_day_post
    date = params.require(:"Export Appointments").permit(:date)["date"]
    professional = params.require(:"professional").permit(:professional_id)
    template_title = export_day_action(date, professional["professional_id"])
    send_file("#{Rails.root}/public/#{template_title}.html", filename: "#{template_title}.html", type: "application/html")
  end

  def export_day_file
    date = Date.today
    template_title = export_day_action(date)
    send_file("#{Rails.root}/public/#{template_title}.html", filename: "#{template_title}.html", type: "application/html")
  end

  def export_day_pre

  end

  def export_day_action(date, professional_id = nil)
    title = "Appointments Grid (#{date})"
    template_title = "output_day_#{date.to_s}"
    file_output_dir = "#{Rails.root}/public/"
    template_file = File.join(Dir.pwd, "app/views/layouts/export/appointments-grid.html.erb")
    if professional_id and professional_id != ""
      professionals = [Professional.find_by_id(professional_id)]
    else
      professionals = Professional.all
    end
    template = self.output(template_title, file_output_dir, template_file, { appointments_list: Appointment.get_day_appointments(date, professional_id = nil), professionals: professionals, day: true, title: title })
    template_title
  end

  private

  # Only allow a list of trusted parameters through.
  def appointment_params
    params.require(:appointment).permit(:observations, :date, :patient_id, :professional_id)
  end

  def output(name, output_dir, template, **options)
    html = File.open(template).read
    erb = ERB.new(html)
    out = erb.result_with_hash(**options)

    # unless File.directory?(dirname)
    #   FileUtils.mkdir_p(dirname)
    # end
    File.write(File.join(output_dir, "#{name}.html"), out)
  end
end
