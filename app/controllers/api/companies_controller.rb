module Api
  class CompaniesController < ApplicationController
    # GET /api/companies
    def index
      render json: CompanySerializer.render(Company.all, root: :companies)
    end

    # GET /api/companies/:id
    def show
      company = Company.find_by(id: params[:id])

      if company
        render json: CompanySerializer.render(company, root: :company)
      else
        render json: { errors: "Couldn't find the Company" }, status: :not_found
      end
    end

    # POST /api/companies
    def create
      company = Company.new(company_params)

      if company.save
        render json: CompanySerializer.render(company, root: :company), status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    # DELETE /api/companies/:id
    def destroy
      company = Company.find_by(id: params[:id])
      if company
        company.destroy
      else
        render json: { errors: "Couldn't find Company" }, status: :not_found
      end
    end

    # PATCH /api/companies/:id
    def update
      company = Company.find_by(id: params[:id])

      return company_update(company) if company

      render json: { errors: "Couldn't find the Company" }, status: :not_found
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end

    def company_update(company)
      if company.update(company_params)
        render json: CompanySerializer.render(company, root: :company)
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end
  end
end
