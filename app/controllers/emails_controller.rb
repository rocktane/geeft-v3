require 'resend'

class EmailsController < ApplicationController
  def send_test_email
    email = {
      from: 'no-reply@geeft.club',
      to: 'y.gouiran@gmail.com',
      subject: 'Test Email',
      html: '<strong>Ceci est un email de test envoyé depuis Resend.</strong>'
    }

    begin
      response = Resend::Emails.send(email)
      Rails.logger.info "Resend API Response: #{response.inspect}"

      # Convertissons la réponse en hash pour un accès plus facile
      response_hash = response.parsed_response.is_a?(Hash) ? response.parsed_response : JSON.parse(response.body)

      if response_hash[:id] || response_hash['id']
        flash[:notice] = "Email envoyé avec succès."
      else
        flash[:alert] = "Échec de l'envoi de l'email."
      end
    rescue => e
      flash[:alert] = "Erreur lors de l'envoi de l'email."
    end

    redirect_to root_path
  end
end
