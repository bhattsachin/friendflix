app.controller("ffSearchCtrl", ['$scope','$http' ,function($scope,$http) {
    $scope.movieName = "";
	$scope.movieList = {};

    $scope.check = function (imovieName) {
		console.log("checking movie Name");
		if ( imovieName !== undefined && imovieName.length >= 3) {
			console.log(imovieName);
			$scope.addMovie(imovieName,false);
		} else {
			$scope.addMovie();
		}
	};
    $scope.addMovie = function (imovieName,isEmpty) {
		console.log("You have added movie");
		var ffUrl = "/movie.json"
		if (isEmpty === undefined) {
			ffUrl  = '/movieEmpty.json'
		}
		$http({
            method: 'GET',
            url: ffUrl,
            data: { 
				movieName : imovieName
			}
			}).success(function (result) {
				console.log(result)
				$scope.movieList = result.movies;
			}).error(function (error) {
                $scope.status = 'Unable to connect' + error.message;
            });
	};
	$scope.check();
}]);
