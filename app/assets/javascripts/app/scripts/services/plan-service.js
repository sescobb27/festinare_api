'use strict';

angular.module('festinare')
  .factory('PlanService', function ($resource) {

    var PlanService = this;
    var Plan = $resource('http://api.festinare.com.co/v1/plans/:plan_id/:action', {
      plan_id: '@plan_id',
      action: '@action'
    }, {});

    PlanService.all = function () {
      return Plan.get().$promise;
    };

    PlanService.select = function (plan) {
      sessionStorage.plan = JSON.stringify(plan);
    };

    PlanService.get = function () {
      return JSON.parse(sessionStorage.plan);
    };

    PlanService.purchase = function (plan_id) {
      return Plan.save({ plan_id: plan_id, action: 'purchase' }).$promise;
    };

    return PlanService;
  });
