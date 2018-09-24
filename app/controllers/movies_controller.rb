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
    redirect = false
    redirect_params = Hash.new
    sort = params[:sort]
    if params[:title]
      redirect_params[:title] = true
      @movies = Movie.order(:title)
      session[:title] = true
      session[:release_date] = false
    elsif params[:release_date]
      redirect_params[:release_date] = true
      @movies = Movie.order(:release_date)
      session[:title] = false
      session[:release_date] = true
    elsif session[:release_date]
      redirect = true
      redirect_params[:release_date] = true
      session[:title] = false
      session[:release_date] = true
    elsif session[:title]
      redirect = true
      redirect_params[:title] = true
      session[:title] = true
      session[:release_date] = false
    else
      @movies = Movie.all
    end
    @all_ratings = Movie.get_appropriate_rating
    @param_ratings = @all_ratings.select do |rating|
        params["rating_"+rating]
      end
    if not @param_ratings.empty?
      @all_ratings.each do |rating|
        session["rating_"+rating] = params["rating_"+rating]
      end
    else 
      redirect = true
    end
    @selected_ratings = @all_ratings.select do |rating|
      session["rating_"+rating]
    end
    if(@selected_ratings.empty?)
      redirect = true
      @selected_ratings = @all_ratings
    end
    @selected_ratings.each do |rating|
      redirect_params["rating_"+rating] = true
    end
    if redirect
      redirect_to movies_path(redirect_params)
    else
      @movies = @movies.where("rating IN (?)", @selected_ratings)
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