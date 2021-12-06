class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  belongs_to :role, optional: true
  validates :name, presence: true
  before_save :assign_role

  def assign_role
    self.role = Role.find_by name: 'Consultor' if role.nil?
  end
end
