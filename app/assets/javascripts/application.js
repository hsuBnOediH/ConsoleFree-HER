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


//Ready function
//check if cookie is enabled in this page
//check if it is in the login page
//set up buttons if in the login page
$(document).ready(function(){

    if (!areCookiesEnabled()){
        alert("Please enable cookie!");
    }

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
            if (key === 13) {
                $('#sign_up_button').trigger('click');
            }
        });

        $("#confirm_password").keypress(function (event) {
            let key = event.which;
            if (key === 13) {
                $('#sign_up_button').trigger('click');
            }
        });

    }

});


//function to change signin mode to signup mode
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


//function to change signup mode to signin mode
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


//function for user login
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


//function for user sign up
function sendSignUp() {

    let username = $("#user_name").val();
    let password = $("#password").val();
    let confirm_password = $("#confirm_password").val();

    if(!(/^([a-zA-Z_]){3,20}$/.test(username))){
        alert("Username must has a length between 3 and 20 characters.");
        alert("Only english characters and '_' are allowed.");
        window.location.reload();
        return;
    }

    if(!(/^([a-zA-Z0-9_]){6,15}$/.test(password))){
        alert("Password must has a length between 6 and 15 characters.");
        alert("Only english characters, numbers and '_' are allowed.");
        window.location.reload();
        return;
    }

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



//function to store username in the cookie every time the user login successful
function setCookie(name,value) {

    let date = new Date();
    date.setTime(date.getTime() + (3*60*60*1000));
    let expires = "; expires=" + date.toUTCString();
    document.cookie = name + "=" + (value || "")  + expires + "; path=/";

}


//function to determine whether the user is allowed to access the page, by finding the username in the cookie
function getCookie(name) {
    let nameEq = name + "=";
    let ca = document.cookie.split(';');
    for(let i=0;i < ca.length;i++) {
        let c = ca[i];
        while (c.charAt(0)===' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEq) === 0) return c.substring(nameEq.length,c.length);
    }
    return null;
}


//function to erase cookie every time the user log out
function eraseCookie() {

    document.cookie = window.location.pathname.split("/")[1].toString() + '=; Max-Age=-99999999;';

    window.location.replace("/");

}


//function to check if cookie is allowed in the page, if not, give an alert
function areCookiesEnabled() {
    try {
        document.cookie = 'cookietest=1';
        var cookiesEnabled = document.cookie.indexOf('cookietest=') !== -1;
        document.cookie = 'cookietest=1; expires=Thu, 01-Jan-1970 00:00:01 GMT';
        return cookiesEnabled;
    } catch (e) {
        return false;
    }
}