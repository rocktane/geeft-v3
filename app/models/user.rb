class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, uniqueness: { message: 'est déjà utilisé. Veuillez en choisir un autre.' }


  has_many :gifts, dependent: :destroy
  has_many :events, dependent: :destroy
end
