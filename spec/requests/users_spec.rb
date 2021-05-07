require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /show' do
    it 'returns http success' do
      get '/users/show'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/users/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/users/create'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /edit' do
    it 'returns http success' do
      get '/users/edit'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /update' do
    it 'returns http success' do
      get '/users/update'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /destroy' do
    it 'returns http success' do
      get '/users/destroy'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /guest' do
    it 'returns http success' do
      get '/users/guest'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /following' do
    it 'returns http success' do
      get '/users/following'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /followers' do
    it 'returns http success' do
      get '/users/followers'
      expect(response).to have_http_status(:success)
    end
  end
end
