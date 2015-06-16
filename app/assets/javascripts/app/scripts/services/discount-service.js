'use strict';

angular.module('festinare')
  .factory('DiscountService', function ($resource, $q) {

    var DiscountService = this;
    var Discounts = $resource('http://api.festinare.com.co/v1/clients/:client_id/discounts', {
      client_id: '@client_id'
    });

    DiscountService.getDiscounts = function (client_id) {
      return Discounts.get({ client_id: client_id }).$promise;
    };

    DiscountService.createDiscount = function (client_id, discount) {
      var deferred = $q.defer();
      Discounts.save({ client_id: client_id }, { discount: discount}).$promise.then(function (response) {
        deferred.resolve(response.discount);
      }).catch(function (error) {
        deferred.reject(error);
      });
      return deferred.promise;
    };

    return DiscountService;
  });
