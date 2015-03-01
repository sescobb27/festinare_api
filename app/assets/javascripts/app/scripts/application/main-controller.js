'use strict';

angular.module('hurryupdiscount')
  .controller('MainCtrl', function ($scope, $rootScope, $state, $mdToast, AuthService) {

    AuthService.isLoggedIn().then(function (logged_in) {
      $scope.logged_in = logged_in;
    });
    $rootScope.$on('alert', function (event, alert) {
      $mdToast.show({
        controller: 'AlertCtrl',
        templateUrl: 'scripts/components/alert/notification.html',
        locals: {
          alert: alert
        },
        hideDelay: alert.timeout || 10000,
        position: 'top right'
      });
    });

    $rootScope.$on('logout', function () {
      $scope.logout();
    });

    $scope.logout = function () {
      $rootScope.$emit('logout');
      $scope.logged_in = false;
      $state.go('index');
    };

  });
