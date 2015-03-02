'use strict';

angular.module('hurryupdiscount').
  directive('footerBar', function () {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: 'assets/javascripts/app/scripts/directives/footer-bar/footer-bar.html'
    };
  });
