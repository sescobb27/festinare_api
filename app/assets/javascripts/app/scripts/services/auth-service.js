'use strict';

angular.module('hurryupdiscount')
  .factory('AuthService', function ($rootScope, SessionService, $resource, ClientService, $q) {
    var AuthService = this;
    var client_promise = null;
    var client;

    if(SessionService.getCurrentSession()) {
      client_promise = ClientService.get().then(function (res) {
        console.log('CLIENT: ', res);
        client = res.client;
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
          client = res;
          return;
        });
        return client_promise;
      });
    };

    AuthService.register = function(credentials) {

    };

    AuthService.logout = function() {
      client = null;
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

    return AuthService;
  });
