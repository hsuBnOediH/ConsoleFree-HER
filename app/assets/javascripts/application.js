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
    if(window.location.pathname === "/") {
        $("html").css("zoom","0.58");
        $("#sign_up_button").off("click");
        $("#signup_login_button").off("click");
        $("#signup_login_button").on('click', function () {
            changeToSignUp();
        });
        $("#sign_up_button").on("click", function () {
            sendLogIn();
        });


        $("#password").keypress(function (event) {
            let key = event.which;
            if (key == 13) {
                $('#sign_up_button').trigger('click');
            }
        });

        $("#confirm_password").keypress(function (event) {
            let key = event.which;
            if (key == 13) {
                $('#sign_up_button').trigger('click');
            }
        });

    }

});


function changeToSignUp() {
    $("#right_box_top_sign_in").html("Sign Up");
    $("#right_box_body_confirm_password").show();
    $("#signup_login_button span").html("Have Account?");
    $("#sign_up_button span").html("Sign Up");


    $("#signup_login_button").off("click");
    $("#signup_login_button").on("click", function () {
        changeToLogIn();
    });
    $("#sign_up_button").off("click");
    $("#sign_up_button").on("click", function () {
        sendSignUp();
    });


}

function changeToLogIn() {
    $("#right_box_top_sign_in").html("Log In");
    $("#right_box_body_confirm_password").hide();
    $("#signup_login_button span").html("Sign Up Now!");
    $("#sign_up_button span").html("Log In");


    $("#signup_login_button").off("click");
    $("#signup_login_button").on("click", function () {
        changeToSignUp();
    });
    $("#sign_up_button").off("click");
    $("#sign_up_button").on("click", function () {
        sendLogIn();
    });
}

function sendLogIn() {

    let username = $("#user_name").val();
    let password = $("#password").val();

    let user_account = {username: username, password: password};
    let user_account_json = JSON.stringify(user_account);

    $.ajax({
        url: "/users/validate",
        type: "POST",
        data: user_account_json,
        async: false,
        success: function (msg) {
            if (msg.status) {
                let url = "/" + username;
                setCookie(username,password);
                window.location.replace(url);
            } else {
                alert("Incorrect username or password");
                window.location.reload();
            }
        }
    });
}


function sendSignUp() {

    let username = $("#user_name").val();
    let password = $("#password").val();
    let confirm_password = $("#confirm_password").val();

    if (password === confirm_password) {

        let user_account = {username: username, password: password};
        let user_account_json = JSON.stringify(user_account);

        $.ajax({
            url: "/users/create",
            type: "POST",
            data: user_account_json,
            async: false,
            success: function (msg) {
                if (msg.status){
                    let url="/"+ username;
                    setCookie(username,password);
                    window.location.replace(url);
                } else {
                    alert("Username already used, please try another one.");
                    window.location.reload();
                }
            }
        });
    } else {
        alert("Please enter non-empty username or make sure passwords are matched");
        window.location.reload();
    }
}

function setCookie(name,value) {

    let date = new Date();
    date.setTime(date.getTime() + (20*1000));
    let expires = "; expires=" + date.toUTCString();

    document.cookie = name + "=" + (value || "")  + expires + "; path=/";
}

function getCookie(name) {
    let nameEQ = name + "=";
    let ca = document.cookie.split(';');
    for(let i=0;i < ca.length;i++) {
        let c = ca[i];
        while (c.charAt(0)===' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
}

function eraseCookie() {

    document.cookie = window.location.pathname.split("/")[1].toString() + '=; Max-Age=-99999999;';

    window.location.replace("/");
}