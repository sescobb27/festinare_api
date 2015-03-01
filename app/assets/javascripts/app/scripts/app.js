'use strict';

angular
  .module('hurryupdiscount', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngSanitize',
    'ngTouch',
    'ui.router',
    'ngMaterial',
    'ngMessages',
    'uuid',
    'angularFileUpload',
  ])
  .config(function ($stateProvider, $urlRouterProvider, $httpProvider, $locationProvider) {
    $urlRouterProvider.otherwise('/');
    $locationProvider.html5Mode(true);

    $stateProvider
      .state('login', {
        url: '/client/auth/login',
        templateUrl: 'scripts/client/auth/login.html',
        controller: 'ClientAuthCtrl'
      })
      .state('register', {
        url: '/client/auth/register',
        templateUrl: 'scripts/client/auth/register.html',
        controller: 'ClientAuthCtrl'
      })
      .state('dashboard', {
        url:'/client/dashboard',
        templateUrl: 'scripts/client/dashboard/dashboard.html',
        controller: 'ClientDashboardCtrl',
        auth: true
      })
      .state('about-us', {
        url:'/about-us',
        templateUrl: 'scripts/application/about-us.html',
      })
      .state('contact-us', {
        url:'/contact-us',
        templateUrl: 'scripts/application/contact-us.html',
      })
      .state('pricing', {
        url:'/pricing',
        templateUrl: 'scripts/application/pricing.html',
      })
      .state('support', {
        url:'/support',
        templateUrl: 'scripts/application/support.html',
      });

    $httpProvider.interceptors.push('AuthInterceptor');
  })
  .factory('AuthInterceptor', function ($rootScope, $q, SessionService, $location) {
    return {
      // Add authorization token to headers
      request: function (config) {
        config.headers = config.headers || {};
        // console.log('REQUEST: ', config);
        if (SessionService.getCurrentSession()) {
          config.headers.Authorization = 'Bearer ' + SessionService.getCurrentSession();
        }
        return config;
      },

      // Intercept 401s and redirect you to login
      responseError: function(response) {
        console.log('RESPONSE ERROR:', response);
        if(response.status === 401) {
          $location.path('/');
          $rootScope.$emit('logout');
          // remove any state tokens
        }
        return $q.reject(response);
      }
    };
  })
  .run(function ($rootScope, $state, AuthService) {
    // Redirect to login if route requires auth and you're not logged in
    $rootScope.$on('$stateChangeStart', function (event, next) {
      if (next.auth && !AuthService.isLoggedIn()) {
        $state.go('login');
        event.preventDefault();
      }
    });

    $rootScope.$on('$stateChangeSuccess', function (event, toState, toParams, fromState) {
      $state.previous = fromState;
    });

  });
