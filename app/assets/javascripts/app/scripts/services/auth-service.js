'use strict';

angular.module('hurryupdiscount')
  .factory('AuthService', function ($rootScope, SessionService, $resource, ClientService) {
    var AuthService = this;
    var current_user = null;

    if(SessionService.getCurrentSession()) {
      ClientService.get().then(function (client) {
        current_user = client;
      });
    }

    $rootScope.$on('logout', function () {
      AuthService.logout();
    });

    AuthService.login = function(credentials) {
      ClientService.login(credentials).then(function (res) {
        SessionService.addSession(res);
        ClientService.get().then(function (client) {
          current_user = client;
        });
      });
    };

    AuthService.register = function(credentials) {

    };

    AuthService.logout = function() {
      current_user = null;
    };

    // TODO
    AuthService.forgotPassword = function(email) {};
    // TODO
    AuthService.resetPassword = function(token, password) {};
    // TODO
    AuthService.updatePassword = function(oldPassword, newPassword, userId) {};

    AuthService.isLoggedIn = function () {
      return !!current_user;
    };

    AuthService.getCurrentUser = function() {
      return current_user || null;
    };

    return AuthService;
  });
