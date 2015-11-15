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
    
    # sorting/filtering default
    session[:sort_by] ||= ''
    session[:rating_filter] ||= @all_ratings
    
    # user sorting/filtering setting
    session[:sort_by] = params[:sort_by] if params[:sort_by]
    session[:rating_filter] = params[:ratings].keys if params[:ratings]
    
    @sort_by = session[:sort_by]
    @rating_filter = session[:rating_filter]
    if params[:ratings] && params[:sort_by]
      unless @sort_by.empty?
        @movies = Movie.where({ rating: @rating_filter }).
          order(@sort_by.to_sym)
      else
        @movies = Movie.where({ rating: @rating_filter })
      end
    else
      flash.keep
      redirect_to movies_path(sort_by: @sort_by, ratings: ratings_hash)
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
    @rating_filter.map { |r| [r, '1'] }.to_h
  end
end
