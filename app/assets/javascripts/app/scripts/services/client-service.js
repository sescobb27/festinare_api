'use strict';

angular.module('hurryupdiscount')
  .factory('ClientService', function ($resource) {

    var ClientService = this;
    var Client = $resource('/api/v1/client/:action', {
      action: '@action'
    }, {
      login: {
        method: 'POST'
      }
    });

    ClientService.get = function () {
      return Client.get({action: 'me'}).$promise;
    };

    ClientService.login = function (credentials) {
      return Client.login({action: 'login'}, credentials).$promise;
    };

    return ClientService;

  });
