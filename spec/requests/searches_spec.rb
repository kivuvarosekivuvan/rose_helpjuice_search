require 'rails_helper'

RSpec.describe 'Searches API', type: :request do
  describe 'POST /searches' do
    let(:ip) { '123.45.67.89' }

    before do
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(ip)
    end

    it 'creates a new Search for a fresh query' do
      expect {
        post '/searches', params: { query: 'Hello World' }.to_json,
                          headers: { 'CONTENT_TYPE' => 'application/json' }
      }.to change(Search, :count).by(1)

      expect(response).to have_http_status(:ok)
      last = Search.last
      expect(last.query).to eq('hello world')
      expect(last.user_ip).to eq(ip)
    end

    it 'updates existing Search when within timeout and prefix' do
        existing = Search.create!(query: 'hello', user_ip: ip, last_seen_at: 4.minutes.ago)
        post '/searches', params: { query: 'Hello There' }.to_json,
                        headers: { 'CONTENT_TYPE' => 'application/json' }

      expect(Search.count).to eq(1)
      existing.reload
      expect(existing.query).to eq('hello there')
    end

    it 'ignores blank queries' do
        expect {
        post '/searches', params: { query: '   ' }.to_json,
                            headers: { 'CONTENT_TYPE' => 'application/json' }
        }.not_to change(Search, :count)
        expect(response).to have_http_status(:ok)
    end
    end
end
