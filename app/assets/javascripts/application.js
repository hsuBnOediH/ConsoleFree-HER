// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require rails-ujs
//= require turbolinks
//= require bootstrap
//= require_tree .


$(document).ready(function(){
    $("#sign_up_return_button").on('click',function () {
        changeToSignUp();
    }) ;
});


function changeToSignUp(){
    $("#right_box_top_sign_in").html("Sign Up");
    $("#right_box_body_confirm_password").show();
    $("#sign_up_return_button span").html("Have Account?");
    $("#sign_up_button span").html("Sign Up");
    $("#sign_up_return_button").off("click");
    $("#sign_up_return_button").on("click",function () {
        changeToLogIn();
    });
    $("#sign_up_button").off("click");
    $("#sign_up_button").on("click",function () {
        sendSignUp();
    });


}

function changeToLogIn(){
    $("#right_box_top_sign_in").html("Log In");
    $("#right_box_body_confirm_password").hide();
    $("#sign_up_return_button span").html("Sign In Now!");
    $("#sign_up_button span").html("Log In");
    $("#sign_up_return_button").off("click");
    $("#sign_up_return_button").on("click",function () {
        changeToSignUp();
    });
    $("#sign_up_button").off("click");
    $("#sign_up_button").on("click",function () {
        sendLogIn();
    });
}

function sendLogIn(){

}
function sendSignUp() {

}

