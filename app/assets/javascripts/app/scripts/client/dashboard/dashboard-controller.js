'use strict';

angular.module('hurryupdiscount')
  .controller('ClientDashboardCtrl', function ($scope, $rootScope, AuthService, DiscountService) {

    AuthService.getCurrentUser().then(function (client) {
      $scope.client = client;
      DiscountService.getDiscounts(client._id).then(function (discounts) {
        $scope.client.discounts = discounts;
      });
    });

  });
