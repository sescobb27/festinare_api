'use strict';

angular.module('hurryupdiscount')
  .factory('ClientService', function ($resource) {

    var ClientService = this;
    var Client = $resource('/v1/clients/:action', {
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
      return Client.login({action: 'login'}, {client: credentials}).$promise;
    };

    return ClientService;

  });
