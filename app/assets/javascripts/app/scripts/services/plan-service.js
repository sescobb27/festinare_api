'use strict';

angular.module('hurryupdiscount')
  .factory('PlanService', function ($resource) {

    var PlanService = this;
    var Plan = $resource('/v1/plans', {}, {});

    PlanService.all = function () {
      return Plan.get().$promise;
    };

    PlanService.select = function (plan) {
      sessionStorage.plan = JSON.stringify(plan);
    };

    PlanService.get = function () {
      return JSON.parse(sessionStorage.plan);
    };

    return PlanService;
  });
