'use strict';

angular.module('hurryupdiscount').
  directive('navBar', function () {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: 'assets/javascripts/app/scripts/directives/nav-bar/nav-bar.html'
    };
  });
