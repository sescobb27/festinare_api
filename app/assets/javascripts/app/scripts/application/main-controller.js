'use strict';

angular.module('hurryupdiscount')
  .controller('MainCtrl', function ($scope, $rootScope, $state, $mdToast, AuthService) {

    AuthService.subscribe(this);

    this.notify = function () {
      $scope.logged_in = true;
    };

    AuthService.isLoggedIn().then(function (logged_in) {
      $scope.logged_in = logged_in;
    });

    $rootScope.$on('alert', function (event, alert) {
      $mdToast.show({
        controller: 'AlertCtrl',
        templateUrl: 'assets/javascripts/app/scripts/components/alert/notification.html',
        locals: {
          alert: alert
        },
        hideDelay: alert.timeout || 10000,
        position: 'top right'
      });
    });

    $rootScope.$on('logout', function () {
      $scope.logged_in = false;
      $state.go('index');
    });

    $scope.logout = function () {
      $rootScope.$emit('logout');
      $scope.logged_in = false;
      $state.go('index');
    };

  });
