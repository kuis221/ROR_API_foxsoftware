class CarrierMailer < ApplicationMailer

  # shipment - object, recipient - email address
  def send_invitation(shipment, recipient)
    @link = Settings.host + "/shipments/#{shipment.secret_id}"
    mail to: recipient, subject: "Invitation for bidding on shipment"
  end
end
