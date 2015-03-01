'use strict';

angular.module('hurryupdiscount')
  .controller('MainCtrl', function ($scope, $rootScope, $timeout, $mdToast, $animate, AuthService) {

    $scope.isLoggedIn = AuthService.isLoggedIn();
    $rootScope.$on('alert', function (event, alert) {
      $mdToast.show({
        controller: 'AlertCtrl',
        templateUrl: 'scripts/components/application/alert/notification.html',
        locals: {
          alert: alert
        },
        hideDelay: alert.timeout || 10000,
        position: 'top right'
      });
    });
  });
