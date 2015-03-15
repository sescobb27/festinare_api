'use strict';

angular.module('hurryupdiscount')
  .controller('ProfileCtrl', function ($scope, $rootScope, AuthService, ClientService) {

    $scope.categories = {
      'Bar': false,
      'Disco': false,
      'Restaurant': false
    };

    AuthService.getCurrentUser().then(function (client) {
      $scope.client = client;
      if (client.categories && client.categories.length > 0) {
        $scope.disable_categories = true;
      }
      angular.forEach(client.categories, function (category) {
        if ( $scope.categories[category.name] !== undefined ) {
          $scope.categories[category.name] = true;
        }
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
  });
