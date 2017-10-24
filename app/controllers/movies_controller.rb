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
    @movies = Movie.all
    @all_ratings = Movie.ratings
    @ratings_hash = Hash[*@all_ratings.map {|key| [key, 1]}.flatten]

    if (params[:session] == "clear")
      session[:sort_by] = nil
      session[:ratings] = nil
    end

    if (params[:ratings] != nil)
      @ratings_hash = params[:ratings]
      @movies = @movies.where(:rating => @ratings_hash.keys)
      session[:ratings] = @ratings_hash
    end

    if (params[:sort_by] != nil)
      case params[:sort_by]
      when "title"
        @movies = Movie.order(params[:sort_by])
        @class_title = "hilite"
        session[:sort_by] = "title"
      when "release_date"
        @movies = Movie.order(params[:sort_by])
        @class_release_date = "hilite"
        session[:sort_by] = "release_date"
      end


    if (params[:sort_by] == nil || params[:ratings] == nil)
      redirect_hash = (session[:ratings] != nil) ? Hash[*session[:ratings].keys.map {|key| ["ratings[#{key}]", 1]}.flatten] : { :ratings => @ratings_hash }
      redirect_hash[:sort_by] = (session[:sort_by] != nil) ? session[:sort_by] : "none"
      redirect_to movies_path(redirect_hash) and return
    end
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

  def movie
    @all_ratings = "G"
  end

end
