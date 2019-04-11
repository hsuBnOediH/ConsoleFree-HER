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

let entity_num = 1;

$(document).ready(function(){
    // $(".left_frame_row").on('mouseenter',function () {
    //     $(this).css("background-color", "#429AF5");
    // }) ;
    // $(".left_frame_row").on('mouseleave',function () {
    //     $(this).css("background-color", "white");
    // }) ;

});


function add_entity(){
    $('#entities').append('<input id="entity_'+entity_num.toString()+'" value="" type="text" class="form-control">');
    entity_num += 1;
}


function create_repo(){

    // var files = $('#file_upload').prop('files');
    // var data = new FormData();
    // for(let i=0; i<files.length; i++) {
    //     data.append(files[i].toString(), files[i]);
    // }
    let repo_name = $("#repo_name").val();
    let language = $('#language').val();
    let sort_method = $('#sortMethod').val();
    let seed_size = $('#seed_size').val();
    let entities = [];

    for(let i=0; i<entity_num; i++){

        entities.push($('#entity_' + i.toString()).val());
    }

    let files = $('#file_upload').prop('files');
    let data_file = new FormData();
    for(let i=0; i<files.length; i++) {
        data_file.append("file_" + i.toString(), files[i]);
    }

    let gazs = $('#gaz_upload').prop('files');
    let gaz_file = new FormData();
    // for(let i=0; i<gazs.length; i++) {
    //     data_file.append("gazs", gazs[i]);
    // }

    let repo_info = {repo_name: repo_name,
        language: language,
        sort_method: sort_method,
        seed_size: seed_size,
        entities: entities};

    let repo_info_json = JSON.stringify(repo_info);
    // data_file.append('json', repo_info_json)
    $.ajax({
        url: 'users/add_repo',
        type: 'POST',
        data: data_file,
        cache: false,
        async: false,
        processData: false,
        contentType: false
    });

    window.location.reload();


    //window.location.reload();
}





