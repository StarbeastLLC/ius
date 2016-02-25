$(function () {

    var auth2 = {};
    var helper = (function() {
      return {
        /**
         * Hides the sign in button and starts the post-authorization operations.
         *
         * @param {Object} authResult An Object which contains the access token and
         *   other authentication information.
         */
        onSignInCallback: function(authResult) {
          if (authResult.isSignedIn.get()) {
            helper.profile();
          } else {
              if (authResult['error'] || authResult.currentUser.get().getAuthResponse() == null) {
                // There was an error, which means the user is not signed in.
                // As an example, you can handle by writing to the console:
                console.log('There was an error: ' + authResult['error']);
              }
          }

          console.log('authResult', authResult);
        },

        /**
         * Calls the OAuth2 endpoint to disconnect the app for the user.
         */
        disconnect: function() {
          // Revoke the access token.
          auth2.disconnect();
        },

        /**
         * Gets and renders the currently signed in user's profile data.
         */
        profile: function(){
          gapi.client.plus.people.get({
            'userId': 'me'
          }).then(function(res) {
            var profile = res.result;
            if (profile.name) {
                $('#google_auth #user_first_name').val(profile.name.givenName);
                $('#google_auth #user_last_name').val(profile.name.familyName);
            }
            if (profile.emails) {
                $('#google_auth #user_email').val(profile.emails[0].value);
            }
            if (profile.id) {
                $('#google_auth #user_google_id').val(profile.id);
            }
            if (profile.cover && profile.coverPhoto) {
              $('#profile').append(
                  $('<p><img src=\"' + profile.cover.coverPhoto.url + '\"></p>'));
            }
            $('#google_auth').submit();
          }, function(err) {
            var error = err.result;
            $('#profile').empty();
            $('#profile').append(error.message);
          });
        }
      };
    })();

    /**
     * jQuery initialization
     */
    $(document).ready(function() {
      $('#disconnect').click(helper.disconnect);
      $('#loaderror').hide();
      if ($('meta')[0].content == 'YOUR_CLIENT_ID') {
        alert('This sample requires your OAuth credentials (client ID) ' +
            'from the Google APIs console:\n' +
            '    https://code.google.com/apis/console/#:access\n\n' +
            'Find and replace YOUR_CLIENT_ID with your client ID.'
        );
      }
    });

    /**
     * Handler for when the sign-in state changes.
     *
     * @param {boolean} isSignedIn The new signed in state.
     */
    var updateSignIn = function() {
      if (auth2.isSignedIn.get()) {
        helper.onSignInCallback(gapi.auth2.getAuthInstance());
      }else{
        helper.onSignInCallback(gapi.auth2.getAuthInstance());
      }
    }

    /**
     * This method sets up the sign-in listener after the client library loads.
     */
    function startApp() {
      gapi.load('auth2', function() {
        gapi.client.load('plus','v1').then(function() {
          gapi.signin2.render('signin-button', {
              scope: 'https://www.googleapis.com/auth/plus.login',
              fetch_basic_profile: true });
          gapi.auth2.init({fetch_basic_profile: true,
              scope:'https://www.googleapis.com/auth/plus.login'}).then(
                function (){
                  auth2 = gapi.auth2.getAuthInstance();
                  auth2.isSignedIn.listen(updateSignIn);
                  auth2.then(updateSignIn);
                });
        });
      });
    }

    window.startApp = startApp;

});