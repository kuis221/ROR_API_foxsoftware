module UserAdmin
  extend ActiveSupport::Concern

  included do

    rails_admin do
      # excludes for all actions
      # Do not exclude from here, exclude per action (eg: 'list', 'edit')
      # exclude_fields :tokens, :updated_at, :encrypted_password, :reset_password_token, :reset_password_sent_at,
      #                :remember_created_at, :confirmation_token, :address_infos
      list do
        # excludes for index only
        field :id
        field :name
        field :email
        field :roles do
          pretty_value do
            more = ''
            roles = bindings[:object].roles.count
            more = " +#{roles-1}" if roles > 1
            "#{bindings[:object].main_role}#{more}"
          end
        end
        field :provider
        field :bids do
          pretty_value do
            bindings[:object].proposals.count
            # OR  bindings[:view].link_to(bindings[:object].proposals.count, 'url_here')
          end
        end
        field :shipments do
          pretty_value do
            bindings[:object].shipments.count
          end
        end
        field :created_at
      end
      edit do
        exclude_fields :current_sign_in_at, :sign_in_count, :last_sign_in_at, :last_sign_in_ip, :current_sign_in_ip,
                       :confirmed_at, :confirmation_sent_at, :provider, :uid, :rating, :identities, :tokens, :friendships,
                       :confirmation_token, :reset_password_sent_at, :remember_created_at, :unconfirmed_email
      end
      show do
        exclude_fields :tokens, :confirmation_token
      end
    end

  end

end