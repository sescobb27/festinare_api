'use strict';

angular.module('hurryupdiscount')
  .controller('DiscountCtrl', function ($scope, $rootScope, AuthService, DiscountService, $mdDialog) {

    $scope.durations = [10, 20, 30, 60, 90, 120];

    $scope.client = null;
    AuthService.getCurrentUser().then(function (client) {
      $scope.client = client;
    }).catch(function (error) {
      $rootScope.$emit('alert', { msg: error.data.errors.join(' ') });
    });

    var hashtags = function() {
      if ( $scope.hashtags ) {
        return $scope.hashtags.split(/[ ,]+/).filter(Boolean).map(function (hashtag) {
          if (hashtag[0] !== '#') {
            return '#' + hashtag;
          }
          return hashtag;
        });
      }
      return [];
    };

    $scope.create = function () {
      if (!$scope.discountform.$valid) {
        $scope.submitted = true;
        return;
      }

      $scope.discount.hashtags = hashtags();
      DiscountService.createDiscount($scope.client._id, $scope.discount).then(function () {
        $mdDialog.hide($scope.discount);
      }).catch(function (error) {
        $rootScope.$emit('alert', { msg: error.data.errors.join(' ') });
      });
    };
  });
