'use strict';

angular.module('festinare').
  directive('navBar', function () {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: 'assets/javascripts/app/scripts/directives/nav-bar/nav-bar.html'
    };
  });
