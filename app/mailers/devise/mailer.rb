require 'resend'

class Devise::Mailer < Devise.parent_mailer.constantize
  default from: 'no-reply@geeft.club'

  def confirmation_instructions(record, token, opts={})
    @token = token
    send_resend_email(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, token, opts={})
    @token = token
    send_resend_email(record, :reset_password_instructions, opts)
  end

  def unlock_instructions(record, token, opts={})
    @token = token
    send_resend_email(record, :unlock_instructions, opts)
  end

  def email_changed(record, opts={})
    send_resend_email(record, :email_changed, opts)
  end

  def password_change(record, opts={})
    send_resend_email(record, :password_change, opts)
  end

  private

  def send_resend_email(record, action, opts={})
    @resource = record
    @token = opts[:token] if opts[:token]
    template = render_to_string(template_path: "devise/mailer", template_name: action)

    email = {
      from: 'no-reply@geeft.club',
      to: record.email,
      subject: I18n.t("devise.mailer.#{action}.subject"),
      html: template
    }

    Resend::Emails.send(email)
  end
end
