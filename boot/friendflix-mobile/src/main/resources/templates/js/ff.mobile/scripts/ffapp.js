angular.module("FFApp",["ngMaterial","ui.router"])
.config(function($mdThemingProvider,$stateProvider) {

	$mdThemingProvider.theme('default')
	.primaryPalette('light-blue')
    .accentPalette('orange')
    .warnPalette('deep-orange')
    .backgroundPalette('grey');

	$stateProvider.state('new',{
		url :'/new',
		templateUrl : 'components/ffautocomplete/ffautocomplete.tpl.html',
		controller : 'autocompleteController as vm'
	}).state('trending', {
		url :'/trending',
		template :'<h1> Trending shows</h1>',
		controller : function($scope)  {
			$scope.msg = "Hello";
		}
	}).state('share', {
		url :'/share',
		template :'<h1> share with twitter</h1>'
	});
});



