
## Create a demo data for api documentation.
# Also swagger-ui doc folder(api-doc) js modified to use 'set_value' fields that populated by swagger, for auth.

# TODO : user:shipper(with cheated-stored access-token for re-reading) -> shipment ?more


## End demo data

email = "adminx@exxample.com"
unless User.exists?(email: email)
  puts 'Create a user with admin role'
  user = User.new
  user.email = email
  user.first_name = 'Admin'
  user.password = '123qweasd'
  user.password_confirmation = '123qweasd'
  user.confirmed_at = Time.now
  user.save!
  user.create_new_auth_token
  user.add_role :admin
end
