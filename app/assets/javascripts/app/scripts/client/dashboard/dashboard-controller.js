'use strict';

angular.module('festinare')
  .controller('ClientDashboardCtrl', function ($scope, $rootScope, AuthService, DiscountService, $mdDialog) {

    $scope.isLoading = true;
    AuthService.getCurrentUser().then(function (client) {
      $scope.client = client;
      DiscountService.getDiscounts(client._id).then(function (res) {
        $scope.client.discounts = res.discounts;
        angular.forEach($scope.client.discounts, function (discount) {
          var tmp = new Date(discount.created_at);
          discount.until_date = new Date(tmp.getTime() + (discount.duration * 60000));
        });
        if ( client.client_plans && client.client_plans.length > 0) {
          $scope.current_plan = client.client_plans[0];
        }
        $scope.isLoading = false;
      }).catch(function (error) {
        $scope.isLoading = false;
        $rootScope.$emit('alert', { msg: error.data.errors.join(' ') });
      });
    });

    $scope.hashtags = function (hashtags) {
      return hashtags ? hashtags.join(' ') : '';
    };

    $scope.createDiscount = function ($event) {
      $mdDialog.show({
        templateUrl: 'assets/javascripts/app/scripts/client/dashboard/discount/new-discount-modal.html',
        controller: 'DiscountCtrl',
        targetEvent: $event
      }).then(function(disount) {
        $scope.client.discounts.push(disount);
        $scope.current_plan.num_of_discounts_left--;
      });
    };

  });
