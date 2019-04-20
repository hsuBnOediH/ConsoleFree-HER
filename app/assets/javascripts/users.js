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


let entity_num = 1;
let user_num = 1;

$(document).ready(function(){


    if(window.location.pathname.split('/').length < 3 && window.location.pathname.split('/')[1].length>0){
        let x = getCookie(window.location.pathname.split("/")[1].toString());
        if (x) {
            $("html").css("zoom","0.81");
        }else{
            $("#main_page").hide();
            window.location.replace("/");
        }
    }


});


function add_entity(){
    $('#entities').append('<input id="entity_'+entity_num.toString()+'" value="" type="text" class="form-control">');
    entity_num += 1;
}

function add_user(){
    $('#users').append('<input id="user_'+user_num.toString()+'" value="" type="text" class="form-control">');
    user_num += 1;
}

function share_repo(button){
    let users = "";
    for(let i=0; i<entity_num; i++){

        users += $('#user_' + i.toString()).val() + " ";
    }

    let user_info_json = JSON.stringify({users: users, url:button.id.toString()});
    let a = window.location.pathname+'/';

    $.ajax({
        url: a+'share_repo',
        type: 'POST',
        data: user_info_json,
        cache: false,
        async: false,
        processData: false,
        contentType: false,
        success: function(msg){
            alert("Successful Added: " + msg.success_s.toString() + " Failed Added: " + msg.fail_s.toString());
            window.location.reload();
        }
    });
}

function get_repo_user(button){

    let info_json = JSON.stringify({url: button.id.toString().substring(4)});

    let a = window.location.pathname+'/';

    $.ajax({
        url: a+'get_repo_user',
        type: 'POST',
        data: info_json,
        cache: false,
        async: false,
        processData: false,
        contentType: false,
        success: function(msg){

            let names = msg.username.split(" ");

            $('#users_repo_list').empty();
            for (let i=0; i<names.length; i++){
                $('#users_repo_list').append('<p>'+names[i]+'</p>');
            }
        }
    });
}

function delete_repo(button){

    let info_json = JSON.stringify({url: button.id.toString().substring(7)});

    let a = window.location.pathname+'/';

    $.ajax({
        url: a+'delete_repo',
        type: 'POST',
        data: info_json,
        cache: false,
        async: false,
        processData: false,
        contentType: false,
        success: function(msg){

            if (msg.status){
                alert("Delete Success");
            }
            window.location.reload();
        }
    });


}



function create_repo(){
    let repo_name = $("#repo_name").val();
    let language = $('#language').text().substring(10,12);
    let sort_method = $('#sortMethod').text().substring(12);
    let seed_size = $('#seed_size').val();
    let entities = "";

    for(let i=0; i<entity_num; i++){

        entities +=　$('#entity_' + i.toString()).val() + "_";
    }


    let repo_info = {repo_name:repo_name,
        language: language,
        sort_method: sort_method,
        seed_size: seed_size,
        entities: entities};

    let repo_info_json = JSON.stringify(repo_info);

    let a = window.location.pathname+'/';

    $.ajax({
        url: a+'add_repo',
        type: 'POST',
        data: repo_info_json,
        cache: false,
        async: false,
        processData: false,
        contentType: false,
        success: function(msg){
            let filesInfo;
            if (msg.status) {
                let file = $('#file_upload').prop('files');

                recursive_upload(file, 0, a + 'cp_file');

                let gaz = $('#gaz_upload').prop('files');

                recursive_upload(gaz, 0, a + 'cp_gaz');


                filesInfo = {};
                filesInfo.name= repo_name;

                let fileArray = [];
                let gazArray=[];
                for (let i = 0; i < file.length; i++) {
                    fileArray.push(file[i].name.toString())
                }
                for(let i= 0; i<gaz.length;i++){
                    gazArray.push(gaz[i].name.toString())
                }

                filesInfo.fileArray = fileArray;
                filesInfo.gazArray = gazArray;

                let repo = JSON.stringify(filesInfo);
                $.ajax({
                    url: a + "generate_seed",
                    type: 'POST',
                    data: repo,
                    cache: false,
                    async: false,
                    processData: false,
                    contentType: false,
                    success: function () {
                        alert("Repo Created.");
                    }
                });

            }else{
                alert("Repo Name duplicated. Please try another name.");
            }
        }
    });

    window.location.reload();
}


function recursive_upload(data, index, path){

    if (index >= data.length){
        return;
    }

    let data_form = new FormData();
    data_form.append('file', data[index]);
    $.ajax({
        url: path,
        type: 'POST',
        data: data_form,
        cache: false,
        async: false,
        processData: false,
        contentType: false,
        success: function(msg){
            if (msg.status) {
                recursive_upload(data, index + 1, path);
            }
        }
    });
}


function _cancel(){
    window.location.reload();
}

function change_language(language_selection){

    $("#language").text("Language: " + language_selection.innerHTML.toString());

}

function change_sortMethod(sortMethod_selection){

    $("#sortMethod").text("SortMethod: " + sortMethod_selection.innerHTML.toString());

}