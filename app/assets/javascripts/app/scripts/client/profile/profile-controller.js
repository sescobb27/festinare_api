'use strict';

angular.module('hurryupdiscount')
  .controller('ProfileCtrl', function ($scope, $rootScope, AuthService, ClientService) {

    AuthService.getCurrentUser().then(function (client) {
      $scope.client = client;
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
  });
