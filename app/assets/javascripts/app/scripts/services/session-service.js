'use strict';

angular.module('hurryupdiscount')
  .service('SessionService', function ($cookies, $rootScope) {

    var SessionService = this;
    $rootScope.$on('logout', function () {
      SessionService.removeCurrentSession();
    });

    this.addSession = function(data) {
      $cookies.token = data.token;
    };

    this.removeCurrentSession = function() {
      delete $cookies.token;
    };

    this.getCurrentSession = function() {
      return $cookies.token;
    };
  });
