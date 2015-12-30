 'use strict';

angular.module('friendflixApp')
    .factory('notificationInterceptor', function ($q, AlertService) {
        return {
            response: function(response) {
                var alertKey = response.headers('X-friendflixApp-alert');
                if (angular.isString(alertKey)) {
                    AlertService.success(alertKey, { param : response.headers('X-friendflixApp-params')});
                }
                return response;
            }
        };
    });
