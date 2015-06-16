'use strict';

angular.module('festinare')
  .service('SessionService', function ($cookies) {

    var SessionService = this;

    SessionService.addSession = function(data) {
      $cookies.put('token', data.token);
    };

    SessionService.removeCurrentSession = function() {
      $cookies.remove('token');
    };

    SessionService.getCurrentSession = function() {
      return $cookies.get('token');
    };
  });
