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
//= require bootstrap
//= require turbolinks
//= require_tree

$(document).ready(function(){
    // $(".left_frame_row").on('mouseenter',function () {
    //     $(this).css("background-color", "#429AF5");
    // }) ;
    // $(".left_frame_row").on('mouseleave',function () {
    //     $(this).css("background-color", "white");
    // }) ;


    generate_repo_cards();
});

function generate_repo_cards(){

    let pathname = window.location.pathname;

    $.ajax({
        url: pathname+"/get_repo_info", type: "GET", dataType: "json", success: function(msg){
            $("#repo_cards").empty();

            //*************************************
            //extract details of repo information
            $("#repo_cards").append('<div>'+msg.sentence.toString()+'</div>');
            $("#repo_cards").append('<div>SSSS</div>');
            //*************************************
        }
    });

}



