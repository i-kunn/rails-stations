require 'rails_helper'

RSpec.describe MoviesController, type: :controller do
  render_views
  describe 'Station1 GET /movies' do
    before do
      @movies = create_list(:movie, 3)
      get 'index', as: :html
    end

    it '200を返すこと' do
      expect(response).to have_http_status(200)
    end

    it 'HTMLを返すこと' do
      expect(response.body).to include('<!DOCTYPE html>')
    end

    it 'HTMLの中にはmoviesテーブルのレコード数と同じ件数のデータがあること' do
      expect(response.body).to include(@movies[0].title)
      expect(response.body).to include(@movies[1].title)
      expect(response.body).to include(@movies[2].title)
      expect(response.body).to include(@movies[0].image_url)
      expect(response.body).to include(@movies[1].image_url)
      expect(response.body).to include(@movies[2].image_url)
    end
  end
end
