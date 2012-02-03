class Checklist
  
  include Mongoid::Document
    
  embedded_in :user
  
  field   :read_welcome_message,          type: Boolean,          default: false
  field   :read_recruiting_message,        type: Boolean,          default: false
  
  def completed?
    return false unless read_welcome_message
    true
  end
    
end