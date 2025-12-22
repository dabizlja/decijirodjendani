class PagesController < ApplicationController
  def home
    @user = User.new
    @sign_in_user = User.new
    @show_sign_in_modal = ActiveModel::Type::Boolean.new.cast(params[:show_sign_in_modal])
    @categories = Category.where(active: true).order(:name)
    @cities = City.where(active: true).order(:name)
    @price_bounds = Business.price_bounds
    @selected_price_min = (params[:price_min].presence || @price_bounds[:min]).to_i
    @selected_price_max = (params[:price_max].presence || @price_bounds[:max]).to_i
    @featured_businesses = Business.includes(:category, :city, :tags, images_attachments: :blob).last(9)
  end

  private

end
