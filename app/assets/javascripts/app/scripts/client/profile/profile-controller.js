'use strict';

angular.module('hurryupdiscount')
  .controller('ProfileCtrl', function ($scope, $rootScope, AuthService, ClientService) {

    $scope.isLoading = true;
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
      $scope.isLoading = false;
    });

    $scope.triggerFile = function ($event) {
      angular.element('#imagefield').trigger('click');
      $event.stopPropagation();
    };

    $scope.setProfileImage = function (imageUrl) {
      $scope.client.image_url = imageUrl;
      // ClientService.update({image_url: imageUrl}).then(function () {

      // });
    };

    $scope.deleteAddress = function (index) {
      $scope.client.addresses.splice(index, 1);
    };

    $scope.addAddress = function (address) {
      var tmp = address.trim();
      if (tmp.length > 0) {
        $scope.client.addresses.push(address);
        $scope.address = '';
      }
    };

    $scope.updateProfile = function () {
      if ( !$scope.profileForm.$valid ) {
        $scope.submitted = true;
        return;
      }

      $scope.isLoading = true;
      ClientService.update($scope.client._id, $scope.client).then(function () {
        $scope.isLoading = false;
      }).catch(function (error) {
        $rootScope.$emit('alert', { msg: error.data.errors.join(' ') });
        $scope.isLoading = false;
      });
    };

    $scope.changePassword = function (current_password, password, password_confirmation) {
      if ( !$scope.profileForm.$valid ) {
        $scope.submitted = true;
        return;
      }
      if (password !== password_confirmation) {
        error('Passwords do not match');
      } else {
        $scope.isLoading = true;
        ClientService.update($scope.client._id, {
          current_password: current_password,
          password: password,
          password_confirmation: password_confirmation
        }).then(function () {
          $scope.isLoading = false;
        }).catch(function (error) {
          $rootScope.$emit('alert', { msg: error.data.errors.join(' ') });
          $scope.isLoading = false;
        });
      }
    };
  });
