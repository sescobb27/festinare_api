'use strict';

angular.module('festinare')
  .controller('ClientAuthCtrl', function ($scope, $rootScope, $state, AuthService) {

    AuthService.isLoggedIn().then(function (logged_in) {
      if (logged_in) {
        console.log('LOGGED IN');
        $state.go('dashboard');
        return;
      }
    });
    $scope.login = function () {
      if (!$scope.loginform.$valid) {
        $scope.submitted = true;
        return;
      }

      AuthService.login($scope.user).then(function () {
        $state.go('profile');
      }).catch(function () {
        $rootScope.$emit('alert', { msg: 'Invalid username or password' });
      });
    };

  });
