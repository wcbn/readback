class DjsController < ApplicationController
  before_action :set_dj, only: [:show, :edit, :update, :destroy]
  layout "headline"

  # GET /djs
  # GET /djs.json
  def index
    djs = Dj.all
    @trainees = djs.reject(&:active).sort_by(&:created_at).reverse
    non_trainees = djs - @trainees
    @active_djs = non_trainees.select{ |dj| dj.semesters_count > 0 }.sort_by(&:name)
    @trained = (non_trainees - @active_djs).sort_by(&:name)
  end

  # GET /djs/1
  # GET /djs/1.json
  def show
  end

  # GET /djs/new
  def new
    @dj = Dj.new
  end

  # GET /djs/1/edit
  def edit
  end

  # POST /djs
  # POST /djs.json
  def create
    @dj = Dj.new(dj_params)
    @dj.stage1 = "#{Date.today.to_date}"

    respond_to do |format|
      if @dj.save
        flash[:notice] = 'Got it! Welcome to WCBN'
        format.html { redirect_to action: 'new' }
        format.json { render :show, status: :created, location: @dj }
      else
        format.html { render :new }
        format.json { render json: @dj.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /djs/1
  # PATCH/PUT /djs/1.json
  def update
    respond_to do |format|
      if @dj.update(dj_params)
        format.html { redirect_to @dj, notice: 'Dj was successfully updated.' }
        format.json { render :show, status: :ok, location: @dj }
      else
        format.html { render :edit }
        format.json { render json: @dj.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /djs/1
  # DELETE /djs/1.json
  def destroy
    @dj.destroy
    respond_to do |format|
      format.html { redirect_to djs_url, notice: 'Dj was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dj
      @dj = Dj.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dj_params
      params.require(:dj).permit(:name, :phone, :email, :umid, :um_affiliation, :um_dept, :experience, :referral, :interests, :statement)
    end
end
