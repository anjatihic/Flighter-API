module Api
  class CompaniesController < ApplicationController
    before_action :token_match, only: [:create, :update, :destroy]

    # GET /api/companies ---> available to everyone
    def index
      render json: CompanySerializer.render(Company.all, root: :companies)
    end

    # GET /api/companies/:id ----> available to everyone
    def show
      company = Company.find(params[:id])

      render json: CompanySerializer.render(company, root: :company)
    end

    # POST /api/companies
    def create
      unless current_user.admin?
        render json: { errors: { resource: ['forbidden'] } }, status: :forbidden
      end

      company = Company.new(company_params)

      if company.save
        render json: CompanySerializer.render(company, root: :company), status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    # DELETE /api/companies/:id
    def destroy
      unless current_user.admin?
        render json: { errors: { resource: ['forbidden'] } }, status: :forbidden
      end

      company = Company.find(params[:id])

      company.destroy
    end

    # PATCH /api/companies/:id
    def update
      unless current_user.admin?
        render json: { errors: { resource: ['forbidden'] } }, status: :forbidden
      end

      company = Company.find(params[:id])

      return company_update(company) if company
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
