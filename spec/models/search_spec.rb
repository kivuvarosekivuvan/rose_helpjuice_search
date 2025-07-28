require 'rails_helper'

RSpec.describe Search, type: :model do
  it { is_expected.to respond_to(:query) }
  it { is_expected.to respond_to(:user_ip) }
  it { is_expected.to respond_to(:last_seen_at) }

  it 'is invalid without a query' do
    s = Search.new(user_ip: '1.2.3.4', last_seen_at: Time.current)
    expect(s).not_to be_valid
  end

  it 'is invalid without a user_ip' do
    s = Search.new(query: 'foo', last_seen_at: Time.current)
    expect(s).not_to be_valid
  end
end



class Search < ApplicationRecord
  validates :query,   presence: true
  validates :user_ip, presence: true
end
