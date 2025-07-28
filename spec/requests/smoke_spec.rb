require 'rails_helper'

RSpec.describe 'API smoke', type: :request do
  it 'logs a search and then returns it in trends' do
    post '/searches',
      params: { query: 'Im here doing test' }.to_json,
      headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:ok)

    get '/analytics/trends'
    json = JSON.parse(response.body)

    # keys are stored downcased/punct‑stripped
    key = 'im here doing test'
    expect(json.keys).to include(key)
    expect(json[key]['total']).to eq(1)
    expect(json[key]['pct']).to eq(100.0)
  end
end
