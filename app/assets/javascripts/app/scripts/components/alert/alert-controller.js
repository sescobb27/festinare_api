'use strict';

angular.module('festinare')
  .controller('AlertCtrl', function ($scope, $mdToast, alert) {
    $scope.alert = alert;
    $scope.close = function() {
      $mdToast.hide();
    };
  });
