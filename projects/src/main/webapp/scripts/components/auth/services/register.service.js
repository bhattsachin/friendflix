'use strict';

angular.module('friendflixApp')
    .factory('Register', function ($resource) {
        return $resource('api/register', {}, {
        });
    });


