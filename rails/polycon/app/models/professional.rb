class Professional < ApplicationRecord
  has_many :appointments, dependent: :restrict_with_error
  has_many :patients, :through => :appointments

  def to_s
    "#{self.first_name} #{self.last_name} (#{self.id})"
  end

  before_destroy :cannot_delete_with_appointments, prepend: true do
    throw(:abort) if errors.present?
  end

  def cancell_all_appointments
    Appointment.delete_by_professional(self.id)
  end

  private

  def cannot_delete_with_appointments
    errors.add(:base, 'Cannot delete Professional with appointments') if appointments.count > 0
  end

  ##
  # Exceptions
  #
  class DestroyError < StandardError
  end

end
