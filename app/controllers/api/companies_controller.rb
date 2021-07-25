module Api
  class CompaniesController < ApplicationController
    # GET /api/companies
    def index
      render json: CompanySerializer.render(Company.all, root: :companies)
    end

    # GET /api/companies/:id
    def show
      company = Company.find(params[:id])

      render json: CompanySerializer.render(company, root: :company)
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
      company = Company.find(params[:id])

      company.destroy
    end

    # PATCH /api/companies/:id
    def update
      company = Company.find(params[:id])

      if company.update(company_params)
        render json: CompanySerializer.render(company, root: :company)
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    private

    def company_params
      params.permit(:name)
    end
  end
end
