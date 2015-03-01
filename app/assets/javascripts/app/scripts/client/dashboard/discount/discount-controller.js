'use strict';

angular.module('hurryupdiscount')
  .controller('DiscountCtrl', function ($scope, $rootScope, AuthService, DiscountService) {

    $scope.durations = [10, 20, 30, 60, 90, 120];

    $scope.create = function () {
      if (!$scope.disountform.$valid) {
        $scope.submitted = true;
        return;
      }
    };
  });
