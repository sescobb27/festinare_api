'use strict';

angular.module('festinare')
  .controller('DiscountCtrl', function ($scope, $rootScope, AuthService, DiscountService, $mdDialog) {

    $scope.durations = [
      10,  // 10 minutes
      20,  // 20 minutes
      30,  // 30 minutes
      60,  // 1 hour             => 60 minutes
      90,  // 1 hour 30 minutes  => 90 minutes
      120, // 2 hours            => 120 minutes
      150, // 2 hours 30 minutes => 150 minutes
      180, // 3 hours            => 180 minutes
      300, // 5 hours            => 300 minutes
      360  // 6 hours            => 360 minutes
    ];

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
      DiscountService.createDiscount($scope.client._id, $scope.discount).then(function (discount) {
        $mdDialog.hide(discount);
      }).catch(function (error) {
        $rootScope.$emit('alert', { msg: error.data.errors.join(' ') });
      });
    };
  });
