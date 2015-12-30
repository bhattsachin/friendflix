#!/bin/bash

DO_NOT_KEEP=true
#DO_NOT_KEEP=false
VERBOSE=true
movie_genre_url='http://api.themoviedb.org/3/genre/movie/list?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'
movie_genre_url_json='genre.json.tmp'
GENERE_DAT='genere.csv'
XTRA_ATTRIBUTES=('images' 'keywords' 'credits' 'videos')
MOVIE_TYPES=('popular' 'upcoming' 'top_rated')
PRE_URL='http://api.themoviedb.org/3/movie'
SUFFIX_URL='?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'
DEST='/tmp/test'
MOVIE_DAT='popular_movies_id.txt'

call_get_movie_genre_url() {
  curl --include \
       --header "Accept: application/json;" ${movie_genre_url} > ${movie_genre_url_json}
  tail -1 ${movie_genre_url_json} > ${movie_genre_url_json%.tmp}
  rm -rf ${movie_genre_url_json}
}

prepare_genere_lookup() {
  GENRE_OP=${movie_genre_url_json%.tmp}
  declare -i __count
  __count=`cat ${GENRE_OP} | jq '.genres | length'`
  declare  -i __idx
  __idx=0

  while [ ${__idx} -ne ${__count} ]
  do
    __id=`cat ${GENRE_OP} | jq --arg __idx $__idx '.genres['$__idx'].id'`
    __name=`cat ${GENRE_OP} | jq --arg __idx $__idx '.genres['$__idx'].name'`
    echo "${__id}	${__name}" 
    echo "${__id}	${__name}" >> ${GENERE_DAT}
    __idx=$(($__idx+1))
  done
}

call_get_request() {
  curl --silent --include \
       --header "Accept: application/json;" ${1} > ${JSON_OP_TMP}

  echo "saved ${1} to ${JSON_OP}"
  tail -1 ${JSON_OP_TMP} > ${JSON_OP}
  rm -rf ${JSON_OP_TMP}
}


count_no_of_pages() {

    JSON_OP_TMP=${$}'.json.tmp'
    JSON_OP=${JSON_OP_TMP%.tmp}
    call_get_request ${1}
    START=0
    TOTAL_PAGES=`cat ${JSON_OP} | jq -r '.total_pages'`
    ${DO_NOT_KEEP} && rm -rf ${JSON_OP}
}

prepare_movie_datasets() {
  
  declare -i __count
  __count=`cat ${JSON_OP} | jq '.results | length'`
  declare  -i __idx
  __idx=0

  while [ ${__idx} -ne ${__count} ]
  do
    __id=`cat ${JSON_OP} | jq --arg __idx $__idx '.results['$__idx'].id'`
    __original_title=`cat  ${JSON_OP} | jq --arg __idx $__idx '.results['$__idx'].original_title'`
    __title=`cat ${JSON_OP} | jq -r --arg __idx $__idx '.results['$__idx'].title'`
    __original_language=`cat ${JSON_OP} | jq -r --arg __idx $__idx '.results['$__idx'].original_language'`
    __release_date=`cat ${JSON_OP} | jq -r --arg __idx $__idx '.results['$__idx'].release_date'`
    __adult=`cat ${JSON_OP} | jq -r --arg __idx $__idx '.results['$__idx'].adult'`
    __genre_id=`cat ${JSON_OP} | jq -r --arg __idx $__idx '.results['$__idx'].genre_ids[]'`
    __genre_id=`echo ${__genre_id} | sed -e 's/ /|/g'`
     echo "${__id}	${__original_title}	${__original_language}	${__release_date}	${__genre_id}	${__adult}" >> ${MOVIES_DAT}
  
  
    __overview=`cat ${JSON_OP} | jq -r --arg __idx $__idx '.results['$__idx'].overview'`
  
    echo "${__id}	${__overview}" >> ${TAGS_DAT} 
    
    __popularity=`cat ${JSON_OP} | jq -r --arg __idx $__idx '.results['$__idx'].popularity'`
    __vote_average=`cat ${JSON_OP} | jq -r --arg __idx $__idx '.results['$__idx'].vote_average'`
    __vote_count=`cat ${JSON_OP} | jq -r --arg __idx $__idx '.results['$__idx'].vote_count'`
  
    echo "${__id}	${__popularity}	${__vote_average}	${__vote_count}" >> ${RATINGS_DAT}
  
    __idx=$(($__idx+1))
  done
}


reset_movie_dataset() {
  MOVIES_DAT=${$}'_movies.csv'
  TAGS_DAT=${$}'_tags.csv'
  RATINGS_DAT=${$}'_ratings.csv'
  cat /dev/null > ${MOVIES_DAT}
  cat /dev/null > ${TAGS_DAT}
  cat /dev/null > ${RATINGS_DAT}
}


init_movie_dataset() {
  reset_movie_dataset

  for i in $(seq $START $TOTAL_PAGES)
  do
    movie_url=${1}
    movie_url+=${i}
    echo "calling ${movie_url} "
    JSON_OP_TMP=${i}
    JSON_OP_TMP+='_'${$}
    JSON_OP_TMP+='_op.json.tmp'
    JSON_OP=${JSON_OP_TMP%.tmp}
    call_get_request ${movie_url}
    prepare_movie_datasets
    ${DO_NOT_KEEP} && rm -rf ${JSON_OP}
  done
}

move_to_dir() {

  mkdir -p ${1}
  mv ${MOVIES_DAT} ${1}/movies.csv
  mv ${TAGS_DAT} ${1}/tags.csv
  mv ${RATINGS_DAT} ${1}/ratings.csv
}

reset_video_dataset() {
  VIDEO_DAT=${$}'_videos.csv'
  cat /dev/null > ${VIDEO_DAT}
}

prepare_video_datasets() {
  declare  -i _idx
  _idx=0
  _movie_id=`cat ${JSON_OP} | jq -r '.id'`
  _count=`cat ${JSON_OP} | jq '.results | length'`
  while [ ${_idx} -ne ${_count} ]
  do
    _id=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].id'`
    _iso_639_1=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].iso_639_1'`
    _key=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].key'`
    _name=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].name'`
    _site=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].site'`
    _size=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].size'`
    _type=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].type'`
     
     echo "${_movie_id}	${_id}	${_iso_639_1}	${_key}	${_name}	${_site}	${_size}	${_type}" >> ${VIDEO_DAT}
    _idx=$(($_idx+1))
  done
}

reset_keyword_dataset() {
  KEYWORD_DAT=${$}'_keywords.csv'
  cat /dev/null > ${KEYWORD_DAT}
}

prepare_keyword_datasets() {
  declare  -i _idx
  _idx=0
  _movie_id=`cat ${JSON_OP} | jq -r '.id'`
  _count=`cat ${JSON_OP} | jq '.keywords | length'`
  while [ ${_idx} -ne ${_count} ]
  do
    _id=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.keywords['$_idx'].id'`
    _name=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.keywords['$_idx'].name'`
     echo "${_movie_id}	${_id}	${_name}" >> ${KEYWORD_DAT}
    _idx=$(($_idx+1))
  done
}

reset_image_dataset() {
  IMAGE_DAT=${$}'_images.csv'
  cat /dev/null > ${IMAGE_DAT}
}

prepare_image_datasets() {
  declare  -i _idx
  _idx=0
  _movie_id=`cat ${JSON_OP} | jq -r '.id'`
  _count=`cat ${JSON_OP} | jq '.backdrops | length'`
  _bid="B"
  _pid="P"
  while [ ${_idx} -ne ${_count} ]
  do
    _aspect_ratio=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.backdrops['$_idx'].aspect_ratio'`
    _file_path=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.backdrops['$_idx'].file_path'`
    _height=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.backdrops['$_idx'].height'`
    _iso_639_1=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.backdrops['$_idx'].iso_639_1'`
    _vote_average=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.backdrops['$_idx'].vote_average'`
    _vote_count=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.backdrops['$_idx'].vote_count'`
    _width=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.backdrops['$_idx'].width'`
     echo "${_movie_id}	${_aspect_ratio}	${_file_path}	${_height}	${_iso_639_1}	${_vote_average}	${_vote_count}	${_width}	${_bid}" >> ${IMAGE_DAT}
    _idx=$(($_idx+1))
  done

  _idx=0
  _count=`cat ${JSON_OP} | jq '.posters | length'`
  while [ ${_idx} -ne ${_count} ]
  do
    _aspect_ratio=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.posters['$_idx'].aspect_ratio'`
    _file_path=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.posters['$_idx'].file_path'`
    _height=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.posters['$_idx'].height'`
    _iso_639_1=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.posters['$_idx'].iso_639_1'`
    _vote_average=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.posters['$_idx'].vote_average'`
    _vote_count=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.posters['$_idx'].vote_count'`
    _width=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.posters['$_idx'].width'`
     echo "${_movie_id}	${_aspect_ratio}	${_file_path}	${_height}	${_iso_639_1}	${_vote_average}	${_vote_count}	${_width}	${_pid}" >> ${IMAGE_DAT}
    _idx=$(($_idx+1))
  done
}

reset_casts_and_crew_datasets() {
  CAST_DAT=${$}'_casts.csv'
  cat /dev/null > ${CAST_DAT}

  CREW_DAT=${$}'_crews.csv'
  cat /dev/null > ${CREW_DAT}
}

prepare_casts_and_crew_datasets() {
  declare  -i _idx
  _idx=0
  _movie_id=`cat ${JSON_OP} | jq -r '.id'`
  _count=`cat ${JSON_OP} | jq '.cast | length'`
  while [ ${_idx} -ne ${_count} ]
  do
    _cast_id=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.cast['$_idx'].cast_id'`
    _character=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.cast['$_idx'].character'`
    _credit_id=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.cast['$_idx'].credit_id'`
    _id=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.cast['$_idx'].id'`
    _name=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.cast['$_idx'].name'`
    _order=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.cast['$_idx'].order'`
    _profile_path=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.cast['$_idx'].profile_path'`
     echo "${_movie_id}	${_cast_id}	${_character}	${_credit_id}	${_id}	${_name}	${_order}	${_profile_path}" >> ${CAST_DAT}
    _idx=$(($_idx+1))
  done

  _count=`cat ${JSON_OP} | jq '.crew | length'`
  _idx=0
  while [ ${_idx} -ne ${_count} ]
  do
    _credit_id=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.crew['$_idx'].credit_id'`
    _department=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.crew['$_idx'].department'`
    _id=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.crew['$_idx'].id'`
    _job=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.crew['$_idx'].job'`
    _name=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.crew['$_idx'].name'`
    _profile_path=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.crew['$_idx'].profile_path'`
     echo "${_movie_id}	${_credit_id}	${_department}	${_id}	${_job}	${_name}	${_profile_path}" >> ${CREW_DAT}
    _idx=$(($_idx+1))
  done
}

### Images
#curl --include  --header "Accept: application/json" 'http://api.themoviedb.org/3/movie/102899/images?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'

#curl --include --header "Accept: application/json" 'http://api.themoviedb.org/3/movie/102899/credits?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'

#curl --include --header "Accept: application/json" 'http://api.themoviedb.org/3/movie/102899/keywords?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'

#curl --include --header "Accept: application/json" 'http://api.themoviedb.org/3/movie/102899/videos?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'



move_to_parent_dir() {

  mkdir -p ${1}

  mv ${CAST_DAT} ${1}/casts.csv
  mv ${CREW_DAT} ${1}/crews.csv
  mv ${IMAGE_DAT} ${1}/images.csv
  mv ${VIDEO_DAT} ${1}/videos.csv
  mv ${KEYWORD_DAT} ${1}/keywords.csv

}

init_all_dataset() {
  reset_casts_and_crew_datasets
  reset_image_dataset
  reset_video_dataset
  reset_keyword_dataset
}

read_movies() {
  
  while read movie_id
  do
    #sleep 1s
    for att in ${XTRA_ATTRIBUTES[@]}
    do
      URL=$PRE_URL'/'$movie_id'/'$att$SUFFIX_URL
      JSON_OP_TMP=${att}
      JSON_OP_TMP+='_'${$}
      JSON_OP_TMP+='_op.json.tmp'
      JSON_OP=${JSON_OP_TMP%.tmp}
      
      call_get_request ${URL}
      
      case "$att" in
        images)
            echo "calling IMGS ${URL} "
            prepare_image_datasets
            ;;
         
        keywords)
            echo "calling keywords ${URL}" 
            prepare_keyword_datasets
            ;;
         
        credits)
            echo "calling credits ${URL}" 
            prepare_casts_and_crew_datasets
            ;;

        videos)
            echo "calling videos ${URL}" 
            prepare_video_datasets
            ;;
        esac
      ${DO_NOT_KEEP} && rm -rf ${JSON_OP}
    done
  done < ${MOVIE_DAT}

}

init_all_dataset
read_movies
move_to_parent_dir ${DEST}



#prepare_genere_lookup
#call_get_movie_genre_url


#'http://api.themoviedb.org/3/movie/popular?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'


#DEST_DIR='popular'
#popular_url='http://api.themoviedb.org/3/movie/popular?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'
#count_no_of_pages ${popular_url}
#popular_url+='&page='
#init_movie_dataset ${popular_url}
#move_to_dir ${DEST_DIR}


#DEST_DIR='upcoming'
#upcoming_url='http://api.themoviedb.org/3/movie/upcoming?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'
#count_no_of_pages ${upcoming_url}
#upcoming_url+='&page='
#init_movie_dataset ${upcoming_url}
#move_to_dir ${DEST_DIR}

#DEST_DIR='top_rated'
#top_rated_url='http://api.themoviedb.org/3/movie/top_rated?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'
#count_no_of_pages ${top_rated_url}
#top_rated_url+='&page='
#init_movie_dataset ${top_rated_url}
#move_to_dir ${DEST_DIR}
