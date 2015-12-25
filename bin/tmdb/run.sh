#!/bin/bash

DO_NOT_KEEP=true
#DO_NOT_KEEP=false
VERBOSE=true
movie_genre_url='http://api.themoviedb.org/3/genre/movie/list?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'
movie_genre_url_json='genre.json.tmp'
GENERE_DAT='genere.csv'

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

#prepare_genere_lookup
#call_get_movie_genre_url


DEST_DIR='popular'
popular_url='http://api.themoviedb.org/3/movie/popular?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'
count_no_of_pages ${popular_url}
popular_url+='&page='
init_movie_dataset ${popular_url}
move_to_dir ${DEST_DIR}


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


