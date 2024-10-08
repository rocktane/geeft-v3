class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	attr_accessor :login

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, uniqueness: true, presence: true

  has_many :gifts, dependent: :destroy
  has_many :events, dependent: :destroy

	def self.find_for_database_authentication(warden_conditions)
			conditions = warden_conditions.dup
			if (login = conditions.delete(:login))
					where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
			elsif conditions.has_key?(:username) || conditions.has_key?(:email)
					where(conditions.to_h).first
			end
	end
end
