'use strict';

angular.module('hurryupdiscount')
  .controller('ClientDashboardCtrl', function ($scope, $rootScope, AuthService, DiscountService, $mdDialog) {

    AuthService.getCurrentUser().then(function (client) {
      $scope.client = client;
      DiscountService.getDiscounts(client._id).then(function (discounts) {
        $scope.client.discounts = discounts;
      });
    });

    $scope.createDiscount = function ($event) {
      $mdDialog.show({
        templateUrl: 'scripts/client/dashboard/discount/new-discount-modal.html',
        controller: 'DiscountCtrl',
        targetEvent: $event
      });
    };

  });
