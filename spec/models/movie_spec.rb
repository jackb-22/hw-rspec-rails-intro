require 'rails_helper'
require 'spec_helper'

describe Movie do
  describe 'searching Tmdb by keyword' do
    it 'calls Faraday gem' do
      expect(Faraday).to receive(:get).and_call_original
      Movie.find_in_tmdb({title: 'hacker'})
    end
    it 'calls Tmdb with valid API key' do
      Movie.find_in_tmdb({title: "hacker", language: "en"})
    end
    it 'returns unsaved movies built from the results' do
      movies = Movie.find_in_tmdb({title: 'Olympics', release_year: '2000'})
      expect(movies.map(&:title)).to eq ['Sydney 2000 Olympics Opening Ceremony', 'Sydney 2000 Olympics Closing Ceremony']
      expect(movies).to all(be_a_new(Movie))
    end
    it 'skips movies already in the database' do
      Movie.create!(title: 'Sydney 2000 Olympics Opening Ceremony', rating: 'R')
      expect(Movie.find_in_tmdb({title: 'Olympics'}).map(&:title)).to eq ['Sydney 2000 Olympics Closing Ceremony']
    end
    it 'rates every movie R' do
      expect(Movie.find_in_tmdb({title: 'Olympics'}).map(&:rating)).to all(eq 'R')
    end
    it 'returns an empty list when nothing matches' do
      stub_request(:get, /api.themoviedb.org/).to_return(body: '{"results":[]}')
      expect(Movie.find_in_tmdb({title: 'zzzz'})).to be_empty
    end
    it 'returns an empty list with an invalid API key' do
      stub_request(:get, /api_key=bad/).to_return(status: 401, body: '{"success":false}')
      expect(Movie.find_in_tmdb({title: 'hacker'}, 'bad')).to be_empty
    end
  end
end
