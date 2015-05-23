class SemestersController < ApplicationController
  before_action :set_semester, only: [:show, :edit, :update, :destroy]
  before_action :set_model, only: [:new, :create]
  layout "headline"

  # GET /semesters
  # GET /semesters.json
  def index
    redirect_to Semester.current
  end

  # GET /semesters/1
  # GET /semesters/1.json
  def show
    @semesters = Semester.all.sort_by(&:beginning).reverse
  end

  # GET /semesters/new
  def new
    @semester = Semester.new
  end

  # GET /semesters/1/edit
  def edit
    @semesters = Semester.all.sort_by(&:beginning).reverse
  end

  # POST /semesters
  # POST /semesters.json
  def create
    copies = JSON.parse params.delete(:shows_to_copy)

    params[:semester][:beginning] = Time.parse(params[:semester][:beginning])
      .change(hour: 6).beginning_of_hour
    @semester = Semester.new(semester_params)

    copies.each do |show_type, shows|
      shows.each do |show|
        s = show_type.constantize.new(
          show_type.constantize.find(show).attributes
            .slice("dj_id", "name", "weekday", "beginning", "ending")
        )
        s.semester = @semester
        s.save
      end
    end

    respond_to do |format|
      if @semester.save
        format.html { redirect_to edit_semester_path @semester }
        format.json { render :show, status: :created, location: @semester }
      else
        format.html { render :new }
        format.json { render json: @semester.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /semesters/1
  # PATCH/PUT /semesters/1.json
  def update
    respond_to do |format|
      if @semester.update(semester_params)
        format.html { redirect_to @semester, notice: 'Semester was successfully updated.' }
        format.json { render :show, status: :ok, location: @semester }
      else
        format.html { render :edit }
        format.json { render json: @semester.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /semesters/1
  # DELETE /semesters/1.json
  def destroy
    @semester.destroy
    respond_to do |format|
      format.html { redirect_to semesters_url, notice: 'Semester was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_semester
      @semester = Semester.find(params[:id])
      shows = @semester.freeform_shows + @semester.specialty_shows + @semester.talk_shows
      @start_times = shows.map{|x| x.sort_times :beginning}.sort_by{|x| x[:sortable]}.uniq
      @shows = shows.group_by{|x| x.sort_times(:beginning)[:sortable]}
    end

    def set_model
      @model = Semester.find(params.delete(:model_id))
      shows = @model.freeform_shows + @model.specialty_shows + @model.talk_shows
      @start_times = shows.map{|x| x.sort_times :beginning}.sort_by{|x| x[:sortable]}.uniq
      @shows = shows.group_by{|x| x.sort_times(:beginning)[:sortable]}
    end

    def semester_params
      hash = {}
      hash.merge! params.require(:semester).permit(:beginning)
      hash.merge! params.slice(:model_id, :shows_to_copy)
    end
end
# Never trust parameters from the scary internet, only allow the white list through.
