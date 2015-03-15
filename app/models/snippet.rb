class Snippet < ActiveRecord::Base
  belongs_to :user
  after_initialize :generate_reference
  after_create     :set_from

  def generate_reference
    self.reference ||= "#{user_id}_#{DateTime.now.to_i}_#{SecureRandom.hex(6)}"
  end

  def set_from
    self.update(from: "#{self.user.first_name} #{self.user.last_name}")
  end

  def to_json(options={})
    options[:except] ||= [:id, :user_id, :created_at, :updated_at]
    super(options)
  end
  
end
