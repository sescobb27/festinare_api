'use strict';

angular.module('festinare')
  .factory('AuthService', function ($rootScope, SessionService, $resource, ClientService, $q) {
    var AuthService = this;
    var client_promise = null;
    var client;
    var subscriptors = [];

    if(SessionService.getCurrentSession()) {
      client_promise = ClientService.get().then(function (res) {
        console.log('CLIENT: ', res.client);
        client = res.client;
        notify(client);
      });
    } else {
      client_promise = $q(function (resolve, reject) { reject(); });
    }

    $rootScope.$on('logout', function () {
      AuthService.logout();
    });

    AuthService.login = function(credentials) {
      return ClientService.login(credentials).then(function (res) {
        SessionService.addSession(res);
        client_promise = ClientService.get().then(function (res) {
          client = res.client;
          notify(client);
          return client;
        });
        return client_promise;
      });
    };

    AuthService.register = function(credentials) {};

    AuthService.logout = function() {
      return ClientService.logout()
        .then(function () {
          return SessionService.removeCurrentSession();
        })
        .then(function () {
          client = null;
          client_promise = $q(function (resolve, reject) { reject(); });
          notify(null);
        });
    };

    // TODO
    AuthService.forgotPassword = function(email) {};
    // TODO
    AuthService.resetPassword = function(token, password) {};
    // TODO
    AuthService.updatePassword = function(oldPassword, newPassword, userId) {};

    AuthService.isLoggedIn = function () {
      return client_promise.then(function () {
        return !!client;
      }).catch(function () {
        return false;
      });
    };

    AuthService.getCurrentUser = function() {
      return client_promise.then(function () {
        return client;
      });
    };

    AuthService.subscribe = function(subscriptor) {
      return subscriptors.push(subscriptor) - 1;
    };

    AuthService.unsuscribe = function(index) {
      subscriptors.splice(index, 1);
    };

    var notify = function(user) {
      angular.forEach(subscriptors, function (subscriptor) {
        subscriptor.notify(user);
      });
    };

    return AuthService;
  });
