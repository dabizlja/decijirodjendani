class PagesController < ApplicationController
  def home
    @categories = Category.where(active: true).order(:name)
    @cities = City.where(active: true).order(:name)
  end
end
