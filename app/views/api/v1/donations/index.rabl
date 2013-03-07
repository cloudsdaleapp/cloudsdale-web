object nil

node(:donation_url) { @donation_url }
child @donation_statistics => :donation_statistics do
  attributes :begins, :deadline, :amount, :goal, :complete, :supporters
end
