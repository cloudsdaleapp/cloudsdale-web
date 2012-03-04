# module Rating
#   
#   field :rating,      type: Hash,     default: {  "persuasive" => [], "ingenious" => [], "fascinating" => [], "informative" => [],
#                                                   "discouraging" => [], "awkward" => [], "boring" => [], "useless" => [],
# 
#                                                   "persuasive_count" => 0, "ingenious_count" => 0, "fascinating_count" => 0, "informative_count" => 0,
#                                                   "discouraging_count" => 0, "awkward_count" => 0, "boring_count" => 0, "useless_count" => 0,
# 
#                                                   "positive_count"=> 0, "negative_count"=> 0, "count"=> 0, "point"=> 0 }
#   
#   POSITIVE = { "persuasive" => 1, "ingenious" => 1, "fascinating" => 1, "informative" => 1 }
#   NEGATIVE = { "discouraging" => -1, "awkward" => -1, "boring" => -1, "useless" => -1 }
#   ALL = NEGATIVE.merge(POSITIVE)
#   KEYS = POSITIVE.keys + NEGATIVE.keys
#   
#   class KeyError < StandardError; end
#   
#   #default_scope order_by(:'votes.score' => :desc, :created_at => :desc)
# 
#   def rate(user,key)
#     if Rating::KEYS.include?(key)
#       purge_current_rating(user)
#       rating[key] = (rating[key] + [user.id]).uniq
#       calculate_rating
#     else
#       raise Rating::KeyError, "#{key} is not a valid key"
#     end
#   end
# 
#   def unrate(user)
#     purge_current_rating(user)
#     calculate_rating
#   end
# 
#   # Fetches what a specific user has rated
#   def rating_by(user)
#     fetch_current_rating(user)
#   end
# 
#   private
# 
#   def purge_current_rating(user)
#     Rating::KEYS.each do |key|
#       rating[key] = rating[key].reject{|id|id==user.id} if rating[key].include?(user.id)
#     end
#   end
# 
#   def fetch_current_rating(user)
#     Rating::KEYS.each do |key|
#       rating[key].include?(user.id) ? key : nil
#     end
#   end
# 
#   def calculate_rating
#     score = 0
#     pos_count = 0
#     neg_count = 0
# 
#     Rating::ALL.each do |key,value|
# 
#       # Counts votes for current key
#       i = rating[key].count
# 
#       # Stores count for current key
#       rating["#{key}_count"] = i
# 
#       # Adds count depending on if it's a positive or negative rating
#       if Rating::POSITIVE.keys.include?(key)
#         pos_count += i
#       elsif Rating::NEGATIVE.keys.include?(key)
#         neg_count += i
#       end
# 
#       # Adds score depending on key
#       score += (value*i)
# 
#     end
# 
#     # Calculates total count of votes based upon negative and positive
#     rating['positive_count'] = pos_count
#     rating['negative_count'] = neg_count
#     rating['count'] = neg_count + pos_count
#     rating['point'] = score
#     timeless.save
#   end
#   
# end