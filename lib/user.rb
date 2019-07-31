class User < ActiveRecord::Base
    has_many :user_clothes
    has_many :clothing, through: :user_clothes
end 