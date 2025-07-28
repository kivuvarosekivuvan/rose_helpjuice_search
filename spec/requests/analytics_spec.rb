require 'rails_helper'

RSpec.describe 'Analytics API', type: :request do
  describe 'GET /analytics/trends' do
    before do
      # create some searches
      Search.create!(query: 'foo', user_ip: '1.1.1.1', last_seen_at: 2.hours.ago)
      Search.create!(query: 'foo', user_ip: '1.1.1.1', last_seen_at: 1.hour.ago)
      Search.create!(query: 'bar', user_ip: '2.2.2.2', last_seen_at: 30.minutes.ago)
    end

    it 'returns counts and percents' do
      get '/analytics/trends'
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['foo']['count']).to eq(2)
      expect(json['bar']['count']).to eq(1)

      total = 3.0
      expect(json['foo']['percent']).to eq((2 / total * 100).round(1))
      expect(json['bar']['percent']).to eq((1 / total * 100).round(1))
    end
  end
end
