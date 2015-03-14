'use strict';

angular.module('hurryupdiscount')
  .controller('PricingCtrl', function ($scope, $rootScope, AuthService, PlanService) {

    PlanService.all().then(function (res) {
      $scope.plans = res.plans;
    });

    $scope.selectPlan = function (planId) {
      angular.forEach($scope.plans, function (plan) {
        if (plan._id.$oid === planId) {
          plan.selected = true;
        } else {
          plan.selected = false;
        }
      });
    };
  });
