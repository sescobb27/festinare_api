'use strict';

angular.module('festinare')
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

    var succes = function (msg) {
      $rootScope.$emit('alert', { msg: msg });
    };

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
        $scope.isLoading = true;
        ClientService.update($scope.client._id, {
          address: address
        }).then(function () {
          succes('Address added!');
          $scope.isLoading = false;
          $scope.client.addresses.push(address);
          $scope.address = '';
        }).catch(function (error) {
          $rootScope.$emit('alert', { msg: error.data.errors.join(' ') });
          $scope.isLoading = false;
        });
      }
    };

    $scope.updateProfile = function () {
      if ( !$scope.profileForm.$valid ) {
        $scope.submitted = true;
        return;
      }

      $scope.isLoading = true;
      ClientService.update($scope.client._id, $scope.client).then(function () {
        succes('Profile updated!');
        $scope.isLoading = false;
      }).catch(function (error) {
        $rootScope.$emit('alert', { msg: error.data.errors.join(' ') });
        $scope.isLoading = false;
      });
    };

    var passwordValidations = function (currentPassword, password, passwordConfirmation) {
      var areEqual = currentPassword !== password;
      $scope.passwordForm.newpass.$setValidity('thesame', areEqual);

      var match = password === passwordConfirmation;
      $scope.passwordForm.confirm.$setValidity('notmatch', match);
    };

    $scope.changePassword = function (currentPassword, password, passwordConfirmation) {
      passwordValidations(currentPassword, password, passwordConfirmation);

      if ( !$scope.passwordForm.$valid ) {
        $scope.submitted = true;
        return;
      }

      $scope.isLoading = true;
      ClientService.update($scope.client._id, {
        password: {
          current_password: currentPassword,
          password: password,
          password_confirmation: passwordConfirmation
        }
      }).then(function () {
        succes('Password updated!');
        $scope.isLoading = false;
      }).catch(function (error) {
        $rootScope.$emit('alert', { msg: error.data.errors.join(' ') });
        $scope.isLoading = false;
      });
    };
  });
