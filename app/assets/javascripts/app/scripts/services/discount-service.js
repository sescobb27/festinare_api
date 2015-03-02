'use strict';

angular.module('hurryupdiscount')
  .factory('DiscountService', function ($resource) {

    var DiscountService = this;
    var Discounts = $resource('/v1/clients/:client_id/discounts', {
      client_id: '@client_id'
    });

    DiscountService.getDiscounts = function (client_id) {
      return Discounts.get({ client_id: client_id }).$promise;
    };

    DiscountService.createDiscount = function (client_id, discount) {
      return Discounts.save({ client_id: client_id }, { discount: discount}).$promise;
    };

    return DiscountService;
  });
