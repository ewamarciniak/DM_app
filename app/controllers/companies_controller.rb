class CompaniesController < ApplicationController
  # GET /companies
  # GET /companies.json
  def index
    company_mapper = Perpetuity[Company]
    @companies = company_mapper.all.to_a
    company_mapper.load_association! @companies, :address

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @companies }
    end
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @company = Perpetuity[Company].find(params[:id])
    Perpetuity[Company].load_association! @company, :address

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/new
  # GET /companies/new.json
  def new
    @company = Company.new
    #@company.build_address

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/1/edit
  def edit
    @company = Perpetuity[Company].find(params[:id])
    Perpetuity[Company].load_association! @company, :address
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new
    params[:company].keys.each do |attribute|
      if attribute == "address"
        params[:company][attribute] = Perpetuity[Address].find(params[:company][attribute])
      end
      @company.send(attribute+"=",params[:company][attribute])
    end
    Perpetuity[Company].insert @company

    respond_to do |format|
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render json: @company, status: :created, location: @company }
    end
  end

  # PUT /companies/1
  # PUT /companies/1.json
  def update
    @company = Perpetuity[Company].find(params[:id])

    params[:company].keys.each do |attribute|
      if attribute == "address"
        params[:company][attribute] = Perpetuity[Address].find(params[:company][attribute])
      end
      @company.send(attribute+"=",params[:company][attribute])
    end
    Perpetuity[Company].save @company

    respond_to do |format|
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { head :no_content }
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company = Perpetuity[Company].find(params[:id])
    Perpetuity[Company].delete @company

    respond_to do |format|
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end
end