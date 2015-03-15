class Snippet < ActiveRecord::Base
  belongs_to :user
  after_initialize :generate_reference

  def generate_reference
    self.reference ||= "#{user_id}_#{DateTime.now.to_i}_#{SecureRandom.hex(6)}"
  end

  def to_json(options={})
    options[:except] ||= [:id, :user_id, :created_at, :updated_at]
    super(options)
  end
  
end
