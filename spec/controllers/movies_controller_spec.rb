require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end
    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with(hash_including(title: 'hardware')).
        and_return(@fake_results)
      get :search_tmdb, params: {title: 'hardware'}
    end
    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: {title: 'hardware'}
      end
      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end
      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end
    it 'shows an error and skips the search when title is blank' do
      expect(Movie).not_to receive(:find_in_tmdb)
      get :search_tmdb, params: {title: ''}
      expect(flash[:danger]).to eq('Please fill in all required fields!')
    end
    it 'shows a message when no movies are found' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])
      get :search_tmdb, params: {title: 'zzzz'}
      expect(flash[:info]).to eq('No movies found with given parameters!')
    end
    it 'shows just the form on first visit' do
      expect(Movie).not_to receive(:find_in_tmdb)
      get :search_tmdb
      expect(flash).to be_empty
    end
  end

  describe 'adding a movie' do
    before :each do
      post :add_movie, params: {movie: {title: 'Manhunter', rating: 'R', release_date: '1986-08-15'}}
    end
    it 'saves the movie to the database' do
      expect(Movie.find_by(title: 'Manhunter')).to be_present
    end
    it 'redirects to the search page with a success message' do
      expect(response).to redirect_to(search_tmdb_path)
      expect(flash[:success]).to eq('Manhunter was successfully added to RottenPotatoes.')
    end
  end
end
