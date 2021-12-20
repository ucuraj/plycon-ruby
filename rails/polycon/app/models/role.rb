class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception
  #The restrict_with_exception option will cause an
  # ActiveRecord::DeleteRestrictionError exception
  # to be raised if you try to delete a Role record, but it has associated User records.
end
