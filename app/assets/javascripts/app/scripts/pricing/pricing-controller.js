'use strict';

angular.module('festinare')
  .controller('PricingCtrl', function ($scope, $rootScope, AuthService, PlanService, $state) {

    var selectedPlan = null;
    PlanService.all().then(function (res) {
      $scope.plans = res.plans;
    });

    $scope.selectPlan = function (planId) {
      angular.forEach($scope.plans, function (plan) {
        console.log(plan);
        if (plan._id === planId) {
          plan.selected = true;
          selectedPlan = plan;
        } else {
          plan.selected = false;
        }
      });
    };

    $scope.purchasePlan = function () {
      if (selectedPlan) {
        PlanService.select(selectedPlan);
        // TODO
        // GOTO PAYU-LATAM or PAYMENT PAGE
        PlanService.purchase(selectedPlan._id).then(function () {
          $state.go('dashboard');
        });
      }
    };
  });
