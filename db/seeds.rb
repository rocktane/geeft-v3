# User.destroy_all
# Event.destroy_all
# Gift.destroy_all
if User.count == 0
  User.create(email: 'yoyo@gmail.com', password: 'pppppp')
end
