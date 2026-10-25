class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
  def self.find_in_tmdb(search_terms, api_key = ENV['TMDB_API_KEY'])
    language = search_terms[:language] unless search_terms[:language] == 'all'
    query = {api_key: api_key, query: search_terms[:title], year: search_terms[:release_year], language: language}
    response = Faraday.get('https://api.themoviedb.org/3/search/movie', query.compact_blank)
    JSON.parse(response.body)['results'].to_a.filter_map do |movie|
      next if exists?(title: movie['title'])
      Movie.new(title: movie['title'], release_date: movie['release_date'], description: movie['overview'], rating: 'R')
    end
  end
end 



