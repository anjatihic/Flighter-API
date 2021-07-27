module Api
  class UsersController < ApplicationController
    # GET /api/users
    def index
      render json: UserSerializer.render(User.all, root: :users), status: :ok
    end

    # GET /api/users/:id
    def show
      user = User.find_by(id: params[:id])

      if user
        render json: UserSerializer.render(user, root: :user)
      else
        render json: { errors: "Couldn't find the User" }, status: :not_found
      end
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
      user = User.find_by(id: params[:id])
      if user
        user.destroy
      else
        render json: { errors: "Couldn't find User" }, status: :not_found
      end
    end

    # PATCH /api/users/:id
    def update
      user = User.find_by(id: params[:id])

      return user_update(user) if user

      render json: { errors: "Couldn't find the User" }, status: :not_found
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email)
    end

    def user_update(user)
      if user.update(user_params)
        render json: UserSerializer.render(user, root: :user)
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end
  end
end
