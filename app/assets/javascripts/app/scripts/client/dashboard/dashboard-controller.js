'use strict';

angular.module('hurryupdiscount')
  .controller('ClientDashboardCtrl', function ($scope, $rootScope, AuthService, DiscountService, $mdDialog) {

    AuthService.getCurrentUser().then(function (client) {
      $scope.client = client;
      DiscountService.getDiscounts(client._id).then(function (res) {
        console.log('DISCOUNTS: ', res.discounts);
        $scope.client.discounts = res.discounts;
      });
    });

    $scope.createDiscount = function ($event) {
      $mdDialog.show({
        templateUrl: 'scripts/client/dashboard/discount/new-discount-modal.html',
        controller: 'DiscountCtrl',
        targetEvent: $event
      }).then(function(disount) {
        $scope.client.discounts.push(disount);
      });
    };

  });
