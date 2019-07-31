class Users_Clothes < ActiveRecord::Base
    belongs_to :user
    belongs_to :clothing
end 