#!/bin/sh


#'http://image.tmdb.org/t/p/original/m1E4v4HH3ivjYlsMjbIMlWfP198.jpg'

### IMAGES
#curl --include  --header "Accept: application/json" 'http://api.themoviedb.org/3/movie/102899/images?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'

# CREDITS/CAST
#curl --include --header "Accept: application/json" 'http://api.themoviedb.org/3/movie/102899/credits?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'

#### KEYWORDS
#curl --include --header "Accept: application/json" 'http://api.themoviedb.org/3/movie/102899/keywords?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'


### TRAILERS


curl --include --header "Accept: application/json" 'http://api.themoviedb.org/3/movie/102899/videos?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'

#https://www.youtube.com/watch?v=ZiS7akYy4yA

#echo"<object width=\"425\" height=\"350\" data=\"http://www.youtube.com/v/$trailer\" type=\"application/x-shockwave-flash\">
#<param name=\"src\" value=\"http://www.youtube.com/v/$trailer\" /></object>";

http://api.themoviedb.org/3/movie/102899/credits?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d
