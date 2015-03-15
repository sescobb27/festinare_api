'use strict';

angular.module('hurryupdiscount')
  .controller('ProfileCtrl', function ($scope, $rootScope, AuthService, ClientService) {

    $scope.categories = [
      {
        name: 'Bar',
        enabled: false,
      },
      {
        name: 'Disco',
        enabled: false,
      },
      {
        name: 'Restaurant',
        enabled: false,
      }
    ];

    AuthService.getCurrentUser().then(function (client) {
      $scope.client = client;
      angular.forEach(client.categories, function (cliCategory) {
        angular.forEach($scope.categories, function (defCategory) {
          if ( defCategory.name === cliCategory.name ) {
            defCategory.enabled = true;
          }
        });
      });
    });

    $scope.triggerFile = function ($event) {
      angular.element('#imagefield').trigger('click');
      $event.stopPropagation();
    };

    $scope.setProfileImage = function (imageUrl) {
      $scope.client.image_url = imageUrl;
      ClientService.update({image_url: imageUrl}).then(function () {

      });
    };

    $scope.updateProfile = function () {
      if ( !$scope.profileForm.$valid ) {
        return;
      }
      // ClientService.update($scope.client).then(function () {

      // }).catch(function (error) {

      // });
    };
  });
