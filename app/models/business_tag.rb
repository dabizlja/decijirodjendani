class BusinessTag < ApplicationRecord
  belongs_to :business
  belongs_to :tag
end
