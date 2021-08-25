module Api
  class CompaniesController < ApplicationController
    before_action :token_match, only: [:create, :update, :destroy]

    # GET /api/companies ---> available to everyone
    def index
      if company_filter_params[:filter] == 'active'
        render json: CompanySerializer.render(Api::CompaniesQuery.new.ordered_companies_with_filter,
                                              root: :companies)
      else
        render json: CompanySerializer.render(Company.order(:name), root: :companies)
      end
    end

    # GET /api/companies/:id ----> available to everyone
    def show
      company = Company.find(params[:id])

      render json: CompanySerializer.render(company, root: :company)
    end

    # POST /api/companies
    def create
      raise ResourceForbiddenError unless current_user.admin?

      company = Company.new(company_params)

      if company.save
        render json: CompanySerializer.render(company, root: :company), status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    # DELETE /api/companies/:id
    def destroy
      raise ResourceForbiddenError unless current_user.admin?

      company = Company.find(params[:id])

      company.destroy
    end

    # PATCH /api/companies/:id
    def update
      raise ResourceForbiddenError unless current_user.admin?

      company = Company.find(params[:id])

      return company_update(company) if company
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end

    def company_filter_params
      params.permit(:filter)
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
