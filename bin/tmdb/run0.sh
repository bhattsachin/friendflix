#!/bin/bash

DO_NOT_KEEP_FILES=true
VERBOSE=true
GENERE_DAT='genere.csv'
XTRA_ATTRIBUTES=('images' 'keywords' 'credits' 'videos')
MOVIE_TYPES=('popular' 'upcoming' 'top_rated')
PRE_URL='http://api.themoviedb.org/3/movie'
SUFFIX_URL='?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'
DEST='/tmp/test'
MOVIE_ID_DAT='op.txt'


prepare_genere_lookup() {
  declare -i _count
  _count=`cat ${JSON_OP} | jq '.genres | length'`
  declare  -i _idx
  _idx=0

  while [ ${_idx} -ne ${_count} ]
  do
    _id=`cat ${JSON_OP} | jq --arg _idx $_idx '.genres['$_idx'].id'`
    _name=`cat ${JSON_OP} | jq --arg _idx $_idx '.genres['$_idx'].name'`
    echo "${_id}	${_name}" 
    echo "${_id}	${_name}" >> ${GENERE_DAT}
    _idx=$(($_idx+1))
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
    ${DO_NOT_KEEP_FILES} && rm -rf ${JSON_OP}
}

prepare_movie_datasets() {
  
  declare -i _count
  _count=`cat ${JSON_OP} | jq '.results | length'`
  declare  -i _idx
  _idx=0

  while [ ${_idx} -ne ${_count} ]
  do
    _id=`cat ${JSON_OP} | jq --arg _idx $_idx '.results['$_idx'].id'`
    _original_title=`cat  ${JSON_OP} | jq --arg _idx $_idx '.results['$_idx'].original_title'`
    _title=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].title'`
    _original_language=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].original_language'`
    _release_date=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].release_date'`
    _adult=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].adult'`
    _genre_id=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].genre_ids[]'`
    _genre_id=`echo ${_genre_id} | sed -e 's/ /|/g'`
     echo "${_id}	${_original_title}	${_original_language}	${_release_date}	${_genre_id}	${_adult}" >> ${MOVIE_DAT}
  
  
    _overview=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].overview'`
  
    echo "${_id}	${_overview}" >> ${TAG_DAT} 
    
    _popularity=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].popularity'`
    _vote_average=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].vote_average'`
    _vote_count=`cat ${JSON_OP} | jq -r --arg _idx $_idx '.results['$_idx'].vote_count'`
  
    echo "${_id}	${_popularity}	${_vote_average}	${_vote_count}" >> ${RATING_DAT}
  
    _idx=$(($_idx+1))
  done
}


reset_movie_dataset() {
  MOVIE_DAT=${$}'_movies.csv'
  TAG_DAT=${$}'_tags.csv'
  RATING_DAT=${$}'_ratings.csv'
  cat /dev/null > ${MOVIE_DAT}
  cat /dev/null > ${TAG_DAT}
  cat /dev/null > ${RATING_DAT}
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
    ${DO_NOT_KEEP_FILES} && rm -rf ${JSON_OP}
  done
}

move_to_dir() {

  mkdir -p ${1}
  mv ${MOVIE_DAT} ${1}/movies.csv
  mv ${TAG_DAT} ${1}/tags.csv
  mv ${RATING_DAT} ${1}/ratings.csv
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
    sleep 5s
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
      ${DO_NOT_KEEP_FILES} && rm -rf ${JSON_OP}
    done
  done < ${MOVIE_ID_DAT}

}

get_all_movies() {
  for movie_type_ in ${MOVIE_TYPES[@]}
  do
    DEST_DIR=${movie_type_}
    URL=${PRE_URL}'/'${movie_type_}$SUFFIX_URL
    count_no_of_pages ${URL}
    URL+='&page='
    init_movie_dataset ${URL}
    move_to_dir ${DEST_DIR}
  done
}

get_genere() {
  URL=${PRE_URL}'/list'$SUFFIX_URL
  JSON_OP_TMP='genere'
  JSON_OP_TMP+='_'${$}
  JSON_OP_TMP+='_op.json.tmp'
  JSON_OP=${JSON_OP_TMP%.tmp}
  call_get_request ${URL}
  prepare_genere_lookup
}


__main() {

  #get_genere

  #'http://api.themoviedb.org/3/movie/popular?api_key=2ff3bf786f52b1bd5ad0b69f2ec10c9d'
  get_all_movies

  #init_all_dataset
  #read_movies
  #move_to_parent_dir ${DEST}

}

