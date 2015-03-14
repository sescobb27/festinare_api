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
    // $locationProvider.html5Mode(true);

    $stateProvider
      .state('index', {
        url:'/'
      })
      .state('login', {
        url: '/client/auth/login',
        templateUrl: 'assets/javascripts/app/scripts/client/auth/login.html',
        controller: 'ClientAuthCtrl'
      })
      .state('register', {
        url: '/client/auth/register',
        templateUrl: 'assets/javascripts/app/scripts/client/auth/register.html',
        controller: 'ClientAuthCtrl'
      })
      .state('dashboard', {
        url:'/client/dashboard',
        templateUrl: 'assets/javascripts/app/scripts/client/dashboard/dashboard.html',
        controller: 'ClientDashboardCtrl',
        auth: true
      })
      .state('profile', {
        url:'/client/profile',
        templateUrl: 'assets/javascripts/app/scripts/client/profile/profile.html',
        controller: 'ProfileCtrl',
        auth: true
      })
      .state('about-us', {
        url:'/about-us',
        templateUrl: 'assets/javascripts/app/scripts/application/about-us.html'
      })
      .state('contact-us', {
        url:'/contact-us',
        templateUrl: 'assets/javascripts/app/scripts/application/contact-us.html'
      })
      .state('pricing', {
        url:'/pricing',
        templateUrl: 'assets/javascripts/app/scripts/application/pricing/pricing.html',
        controller: 'PricingCtrl'
      })
      .state('support', {
        url:'/support',
        templateUrl: 'assets/javascripts/app/scripts/application/support.html'
      });

    $httpProvider.interceptors.push('AuthInterceptor');
  })
  .factory('AuthInterceptor', function ($rootScope, $q, SessionService, $location, $injector) {
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
          var $state = $injector.get('$state');
          $rootScope.$emit('logout');
          $state.go('login');
          $rootScope.$emit('alert', { msg: 'You are not authorized to enter here, please Log In' });
          // remove any state tokens
        }
        return $q.reject(response);
      }
    };
  })
  .run(function ($rootScope, $state, AuthService) {
    // Redirect to login if route requires auth and you're not logged in
    $rootScope.$on('$stateChangeStart', function (event, next) {
      if (next.auth) {
        AuthService.isLoggedIn().then(function (logged_in) {
          if (!logged_in) {
            console.log('NO LOGGED IN');
            $state.go('login');
            event.preventDefault();
          }
        });
      }
    });

    $rootScope.$on('$stateChangeSuccess', function (event, toState, toParams, fromState) {
      $state.previous = fromState;
    });

  });
