class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    session[:sort_by] ||= ''
    session[:rating_filter] ||= @all_ratings
    session[:sort_by] = params[:sort_by] unless params[:sort_by].to_s.empty?
    session[:rating_filter] = params[:ratings].keys unless params[:ratings].nil?
    
    @sort_by = session[:sort_by]
    @rating_filter = session[:rating_filter]
    unless params[:ratings].nil? || params[:sort_by].nil?
      unless session[:sort_by].to_s.empty?
        @movies = Movie.where({ rating: session[:rating_filter] }).
          order(session[:sort_by].to_sym)
      else
        @movies = Movie.where({ rating: session[:rating_filter] })
      end
    else
      flash.keep
      redirect_to movies_path(sort_by: session[:sort_by], ratings: ratings_hash)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  private
  def ratings_hash
    session[:rating_filter].map { |r| [r, '1'] }.to_h
  end
end
