'use strict';

angular.module('hurryupdiscount')
  .controller('ClientDashboardCtrl', function ($scope, $rootScope, AuthService, DiscountService, $mdDialog) {

    $scope.isLoading = true;
    AuthService.getCurrentUser().then(function (client) {
      $scope.client = client;
      DiscountService.getDiscounts(client._id).then(function (res) {
        console.log('DISCOUNTS: ', res.discounts);
        $scope.client.discounts = res.discounts;
        angular.forEach($scope.client.discounts, function (discount) {
          var tmp = new Date(discount.created_at);
          discount.until_date = new Date(tmp.getTime() + (discount.duration * 60000));
        });
        $scope.isLoading = false;
      }).catch(function (error) {
        $scope.isLoading = false;
        $rootScope.$emit('alert', { msg: error.message });
      });
    });

    $scope.hashtags = function (hashtags) {
      return hashtags.join(' ');
    };

    $scope.createDiscount = function ($event) {
      $mdDialog.show({
        templateUrl: 'assets/javascripts/app/scripts/client/dashboard/discount/new-discount-modal.html',
        controller: 'DiscountCtrl',
        targetEvent: $event
      }).then(function(disount) {
        $scope.client.discounts.push(disount);
      });
    };

  });
