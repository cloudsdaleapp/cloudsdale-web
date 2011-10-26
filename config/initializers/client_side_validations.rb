# ClientSideValidations Initializer

require 'client_side_validations/simple_form' if defined?(::SimpleForm)
require 'client_side_validations/formtastic'  if defined?(::Formtastic)

# Uncomment the following block if you want each input field to have the validation messages attached.
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  %{
    <div class='clearfix'>
      #{html_tag}
      <label class='message'>#{instance.error_message.first}</label>
    </div>
    }.html_safe
end


module ClientSideValidations::Middleware
  
  class UserGlobalUniqueness < Base
    def response
      if ::User.where("character.#{request.params[:attribute_name]}" => request.params[:value]).excludes("_id" => request.params[:user_id]).count == 0
        self.status = 200
      else
        self.status = 404
      end
      super
    end
  end
  
end