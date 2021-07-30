module Api
  class UsersController < ApplicationController
    before_action :token_match, only: [:index, :show, :destroy, :update]

    # GET /api/users
    def index
      raise ResourceForbiddenError unless current_user.admin?

      render json: UserSerializer.render(User.all, root: :users), status: :ok
    end

    # GET /api/users/:id
    def show
      user = User.find(params[:id])

      raise ResourceForbiddenError unless current_user.admin? || current_user.id == user.id

      render json: UserSerializer.render(user, root: :user)
    end

    # POST /api/users
    def create
      user = User.new(user_params)

      if user.save
        render json: UserSerializer.render(user, root: :user), status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    # DELETE /api/users/:id
    def destroy
      user = User.find(params[:id])

      raise ResourceForbiddenError unless current_user.admin? || current_user.id == user.id

      user.destroy
    end

    # PATCH /api/users/:id
    def update
      user = User.find(params[:id])

      return user_update(user, admin_user_params) if current_user.admin?

      return user_update(user, user_params) if current_user.id == user.id

      raise ResourceForbiddenError
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end

    def admin_user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :role)
    end

    def user_update(user, params)
      if user.update(params)
        render json: UserSerializer.render(user, root: :user)
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end
  end
end
