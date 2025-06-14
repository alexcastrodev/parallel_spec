class UsersController < ApplicationController
  def create
    result = UserContract.new.call(params.permit(:name).to_h)
    if result.success?
      user = User.create(result.to_h)
      if user.persisted?
        Rails.cache.write("user:#{user.id}", user)
        render json: UserSerializer.new(user).serializable_hash, status: :created
      else
        render json: {errors: user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {errors: result.errors.to_h}, status: :unprocessable_entity
    end
  end

  def show
    user = Rails.cache.fetch("user:#{params[:id]}") do
      User.find_by(id: params[:id])
    end
    if user
      render json: UserSerializer.new(user).serializable_hash
    else
      head :not_found
    end
  end

  def update
    user = User.find_by(id: params[:id])
    unless user
      head :not_found and return
    end
    result = UserContract.new.call(params.permit(:name).to_h)
    if result.success?
      if user.update(result.to_h)
        Rails.cache.write("user:#{user.id}", user)
        render json: UserSerializer.new(user).serializable_hash
      else
        render json: {errors: user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {errors: result.errors.to_h}, status: :unprocessable_entity
    end
  end
end
