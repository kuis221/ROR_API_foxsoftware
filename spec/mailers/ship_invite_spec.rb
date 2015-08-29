require 'rails_helper'

RSpec.describe CarrierMailer, type: :mailer do
  let(:email) { FFaker::Internet.email }
  let(:shipment) { create :shipment }
  let(:mail) { CarrierMailer.send_invitation(shipment, email) }

  it 'renders the subject' do
    expect(mail.subject).to match('Invitation for bidding')
  end

  it 'renders the receiver email' do
    expect(mail.to).to eql([email])
  end


  it 'assigns @link' do
    expect(mail.body.encoded).to include "/shipments/#{shipment.id}?invitation=#{shipment.secret_id}"
  end
end
