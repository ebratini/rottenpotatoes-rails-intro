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
    session[:ratings] ||= @all_ratings.map { |rating| [rating, '1'] }.to_h
    
    # set and save user sorting/filtering setting from request
    session[:sort_by] = @sort_by = params[:sort_by] || session[:sort_by]
    session[:ratings] = @ratings = params[:ratings] || session[:ratings]
    
    if params[:ratings] && params[:sort_by]
      unless @sort_by.empty?
        @movies = Movie.where({ rating: @ratings.keys }).
          order(@sort_by.to_sym)
      else
        @movies = Movie.where({ rating: @ratings.keys })
      end
    else
      flash.keep
      redirect_to movies_path(sort_by: @sort_by, ratings: @ratings)
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
end
