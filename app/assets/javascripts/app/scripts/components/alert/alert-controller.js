'use strict';

angular.module('hurryupdiscount')
  .controller('AlertCtrl', function ($scope, $mdToast, alert) {
    $scope.alert = alert;
    $scope.close = function() {
      $mdToast.hide();
    };
  });
