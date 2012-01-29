class Faq
  
  require 'redcarpet'
  
  include Mongoid::Document
  
  field :question,      type: String
  field :answer,        type: String
  field :position,      type: Integer
  
  validates_presence_of :answer, :question, :position
  
  def mk_answer
    options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
    return Redcarpet.new(self.answer, *options).to_html.html_safe
  end
  
end