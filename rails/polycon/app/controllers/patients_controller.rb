class PatientsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /patients or /patients.json
  def index
    @patients = Patient.all
  end

  # GET /patients/1 or /patients/1.json
  def show
    @appointments = Appointment.all.select { |i| i.patient_id == @patient.id }
  end

  # GET /patients/new
  def new
  end

  # GET /patients/1/edit
  def edit
  end

  # POST /patients or /patients.json
  def create
    respond_to do |format|
      if @patient.save
        format.html { redirect_to @patient, notice: "Patient was successfully created." }
        format.json { render :show, status: :created, location: @patient }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /patients/1 or /patients/1.json
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to @patient, notice: "Patient was successfully updated." }
        format.json { render :show, status: :ok, location: @patient }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1 or /patients/1.json
  def destroy
    @patient.destroy
    respond_to do |format|
      format.html { redirect_to patients_url, notice: "Patient was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def patient_params
    params.require(:patient).permit(:first_name, :last_name, :phone)
  end
end
