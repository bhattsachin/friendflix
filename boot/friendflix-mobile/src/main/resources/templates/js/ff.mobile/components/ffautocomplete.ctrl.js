(function() {
    'use strict';
	angular.module('FFApp')
    .controller("autocompleteController", function($scope,$http, $q){
		var vm = this;
		vm.querySearch = querySearch;
		vm.selectedChange = selectedChange;
		vm.deleteShow = deleteShow;
		vm.exploreShow = exploreShow;
        vm.showRecords = [];

        function querySearch (term){
          console.log('in querySearch ' + term)
          var d = $q.defer();
          $http({
            header: 'Content-Type: application/json',
            method: 'GET',
            url: 'data/shows.json',
            data: {term: term}
          }).then(function (result){
            console.log(result.data.fshows)
            d.resolve(result.data.fshows);
          });
          return d.promise;
        }

        function selectedChange(show) {
			console.log( "Showing added eele : " + show )
			if(show != undefined) {
				vm.showRecords.push(show);
			}
        }

		function deleteShow(show) {
			console.log("Removing show " + show)
			var idx = vm.showRecords.indexOf(show);
			console.log("got idx" + idx )
			vm.showRecords.splice(idx,1);
		}	

		function exploreShow() {

		}	

});
})();
