email = "adminx@exxample.com"
unless User.exists?(email: email)
  puts 'Create a user with admin role'
  user = User.new
  user.email = email
  user.password = "123qweasd"
  user.password_confirmation = "123qweasd"
  user.confirmed_at = Time.now
  user.save!
  user.add_role :admin
end
