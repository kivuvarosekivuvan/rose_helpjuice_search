class SearchesController < ApplicationController
  skip_before_action :verify_authenticity_token

  WINDOW = 5.minutes

  def create
    raw       = params[:query].to_s
    cleaned   = I18n.transliterate(raw)
                      .downcase
                      .gsub(/[[:punct:]]/, '')
                      .strip
                      .squeeze(' ')
    return head :ok if cleaned.empty?

    client_ip = request.remote_ip
    cutoff    = WINDOW.ago

    recent = Search.where(user_ip: client_ip)
                    .where('last_seen_at > ?', cutoff)
                    .order(last_seen_at: :desc)
                    .first

    if recent && cleaned.start_with?(recent.query) && cleaned != recent.query
      recent.update!(query: cleaned, last_seen_at: Time.current)
    else
      Search.create!(query: cleaned, user_ip: client_ip, last_seen_at: Time.current)
    end

    head :ok
  end
end
