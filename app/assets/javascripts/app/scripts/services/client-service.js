'use strict';

angular.module('festinare')
  .factory('ClientService', function ($resource) {

    var ClientService = this;
    var Client = $resource('/v1/clients/:action/:id', {
      action: '@action',
      id: '@id'
    }, {
      login: {
        method: 'POST'
      },
      update: {
        method: 'PUT'
      }
    });

    ClientService.get = function () {
      return Client.get({action: 'me'}).$promise;
    };

    ClientService.login = function (credentials) {
      return Client.login({action: 'login'}, {client: credentials}).$promise;
    };

    ClientService.update = function (id, data) {
      return Client.update({ id: id }, {client: data}).$promise;
    };

    return ClientService;

  });
