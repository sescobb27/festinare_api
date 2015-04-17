'use strict';

angular.module('festinare')
  .directive('upload', function (Transloadit, TransloaditSignatureService) {

    return {
      scope: {
        file: '=',
        setProfileImage: '&'
      },
      template: '<md-progress-circular ng-if="isProcessing" class="md-hue-2" md-mode="indeterminate"></md-progress-circular>',
      restrict: 'A',
      controller: function ($scope) {
        $scope.isProcessing = false;

        $scope.$watch('file', function() {
          if (
            typeof $scope.file !== 'undefined' &&
            angular.isArray($scope.file) &&
            $scope.file.length > 0
          ) {
            $scope.upload($scope.file[0]);
          }
        });


        $scope.upload = function(file) {
          $scope.isProcessing = true;

          Transloadit.upload(file, {
            triggerUploadOnFileSelection: true,
            params: {
              auth: { key: '7fba50d0c68e11e484b239b1b170718d' },
              template_id: '956d5800c75b11e4a3ac0976a235c273'
            },
            signature: function(callback) {
              var context = this;
              TransloaditSignatureService.getSignature().then(function (res) {
                context.params.auth.expires = res.expires;
                callback(res.signature);
              });
            },
            processing: function() {
            },
            uploaded: function(assemblyJson) {
              $scope.file = assemblyJson;
              $scope.setProfileImage({value: assemblyJson.results.optimized[0].ssl_url});
              $scope.isProcessing = false;
            },
            error: function(error) {
              $scope.isProcessing = false;
              console.log(error);
            }
          });
        };
      }
    };
  });
