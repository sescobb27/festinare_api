'use strict';

/**
 * @ngdoc directive
 * @description
 * # geocodeDirective
 */
angular.module('hurryupdiscount')
  .directive('loading', function () {
    return {
      restrict: 'E',
      templateUrl: 'assets/javascripts/app/scripts/directives/loading-directive/loading.html'
    };
  });
