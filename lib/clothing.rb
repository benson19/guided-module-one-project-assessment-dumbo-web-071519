class Clothing < ActiveRecord::Base
    has_many :users_clothes
    has_many :users, through: :users_clothes
#- A clothing instance can call a method, that returns an array 
#  of strings of all of the user's names who own that clothing
  def suffer
    self.users.map do |user| 
        user.name
      end
  end
end


# def users_name
#     user_clothes=UsersClothe.all.select do |cloth|
#         cloth.clothing==self
#     end
# user_clothes.map do |cloth|
#     cloth.user.name
# end
#end
