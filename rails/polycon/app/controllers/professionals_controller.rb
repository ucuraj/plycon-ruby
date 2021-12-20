class ProfessionalsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /professionals or /professionals.json
  def index
    @professionals = Professional.all
  end

  # GET /professionals/1 or /professionals/1.json
  def show
    @appointments = Appointment.select { |i| i.professional_id == @professional.id }.select { |i| i.date >= Date.today }

  end

  # GET /professionals/new
  def new
  end

  # GET /professionals/1/edit
  def edit
  end

  # POST /professionals or /professionals.json
  def create
    respond_to do |format|
      if @professional.save
        format.html { redirect_to @professional, notice: "Professional was successfully created." }
        format.json { render :show, status: :created, location: @professional }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @professional.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /professionals/1 or /professionals/1.json
  def update
    respond_to do |format|
      if @professional.update(professional_params)
        format.html { redirect_to @professional, notice: "Professional was successfully updated." }
        format.json { render :show, status: :ok, location: @professional }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @professional.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /professionals/1 or /professionals/1.json
  def destroy
    if @professional.destroy
      respond_to do |format|
        format.html { redirect_to professionals_url, notice: "Professional was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to professionals_url, notice: "Cannot delete Professional with appointments ." }
        format.json { head :no_content }
      end
    end
  end

  def cancel_all_appointments
    Appointment.delete_by_professional(params[:professional])
    respond_to do |format|
      format.html { redirect_to professionals_url, notice: "All appointments cancelled." }
      format.json { head :no_content }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def professional_params
    params.require(:professional).permit(:first_name, :last_name)
  end
end
