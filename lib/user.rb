class User < ActiveRecord::Base
    ##these are methods incase you forget again >.<
    has_many :users_clothes
    has_many :clothings, through: :users_clothes
end 