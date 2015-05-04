'use strict';

angular.module('festinare')
  .service('SessionService', function ($cookies, $rootScope) {

    var SessionService = this;

    SessionService.addSession = function(data) {
      $cookies.token = data.token;
    };

    SessionService.removeCurrentSession = function() {
      delete $cookies.token;
    };

    SessionService.getCurrentSession = function() {
      return $cookies.token;
    };
  });
