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


let uploadTagArray = [];
let availableOptionArray = [];
let color_list = ["#ffffff","#7FDBFF","#0074D9","#FF851B","#FF9179","#FF79c5","#FFFF79","#d281FF","#caff79","#a089ff","#e8ff79"];
let url_path = window.location.pathname + "/";

$(document).ready(function () {
    welcome_alert();
    data_from_server();
    update_cache();
});

function welcome_alert(){

    $.ajax({
        url: url_path+"welcome", type: "GET", dataType: "json", success: function (msg) {
            if(msg.status){
                alert("Welcome! Please finish annotating the seed!");
            }else{
                alert("Welcome! Already finished the seed! Go to the Corpus now!");
            }
        }
    });
}


function data_from_server(){

    $.ajax({
        url: url_path+"get_sentence", type: "GET", dataType: "json", success: function (msg) {
            if(msg.seed_status){
                generate_sentence(msg.sentence[0], msg.sentence[1]);
            }else{
                $('#seed_finish_alert').modal({backdrop: 'static', keyboard: false});

                update_after_seed();
            }
        }
    });
}

function generate_sentence(sentence, entities){

    $("#sentence_block").empty();

    availableOptionArray = [];
    availableOptionArray.push({tag: "0", color: color_list[0]});
    for (let i=0; i<entities.length;i++){
        availableOptionArray.push({tag: entities[i], color: color_list[i+1]});
    }

    uploadTagArray = sentence;
    for (let i = 0; i < sentence.length; i++) {

        let tempSpan = '<span style="background-color:' + getTagColor(sentence[i].tag, availableOptionArray)
            + '"' + ' class ="word" id = "word' + i.toString() + '">' + sentence[i].word + '</span>';
        let tempBlock = '<div class="dropdown" id="dropdown_'+ i.toString() + '">' + tempSpan +'</div>';
        $("#sentence_block").append(tempBlock);
        let dropdownBlock = getDropDown(availableOptionArray, i.toString());
        $("#dropdown_" + i).append(dropdownBlock);
    }
}


function send_data() {

    let jsonArrayStr="";
    uploadTagArray.forEach(function (element){
        jsonArrayStr += JSON.stringify(element) + " "
    });

    $.ajax({
        url: url_path + "send_sentence.json",
        type: "POST",
        data: jsonArrayStr,
        async: false,
        success: function(){
            $.ajax({
                url: url_path+"get_sentence", type: "GET", dataType: "json", success: function (msg) {
                    if(msg.seed_status){
                        generate_sentence(msg.sentence[0], msg.sentence[1]);
                        update_cache();
                    }else{
                        $('#seed_finish_alert').modal({backdrop: 'static', keyboard: false});

                        update_after_seed();
                    }
                }
            });
        }
    });
}


function data_to_server(){

    let jsonArrayStr="";
    uploadTagArray.forEach(function (element){
        jsonArrayStr += JSON.stringify(element) + " "
    });

    $.ajax({
        url: url_path + "send_sentence.json",
        type: "POST",
        data: jsonArrayStr,
        async: false
    });
}


function update_cache(){

    $.ajax({
        url: url_path+"get_cache_data", type: "GET", dataType: "json", success: function (msg) {
            generate_cache_sentence(msg.sentence)
        }
    });
}


function generate_cache_sentence(sentence){

    $("#cache_data").empty();

    for (let i=0; i<sentence.length; i++){
        let str_div = '<div class="history_record" id="cache'+i.toString()+'" onclick="cache_to_annotate(this)">';


        for (let j=0; j<sentence[i].length;j++){
            let index = 0;
            while (sentence[i][j][index] !== "\t"){
                index += 1;
            }
            let tag = sentence[i][j].substring(0,index);
            let word = sentence[i][j].substring(index+1) + "";
            let tempSpan = '<span class="history_record_span">' + word + '</span>';
            str_div += tempSpan;
        }
        str_div += '</div>';
        $("#cache_data").append(str_div);
    }
}


function tag_click(tagButton) {
    let id = tagButton.className.substring(40);
    uploadTagArray[parseInt(id)].tag = tagButton.innerHTML;
    $("#word" + id).css("background-color", getTagColor(tagButton.innerHTML, availableOptionArray));
}


function cache_to_annotate(sentence_div) {

    data_to_server();

    $.ajax({
        url: url_path+'send_annotating_cache',
        type: 'POST',
        data: parseInt(sentence_div.id.substring(5)),
        cache: false,
        processData: false,
        contentType: false,
        async: false,
        success: function(){
            $.ajax({
                url: url_path+"get_cache_sentence", type: "GET", dataType: "json", async: false, success: function (msg) {
                    let sentence = msg.sentence[0];
                    let entities = msg.sentence[1];
                    let sent_map = [];
                    for (let j = 0; j < sentence.length; j++) {
                        let index = 0;
                        while (sentence[j][index] !== "\t") {
                            index += 1;
                        }
                        let tag = sentence[j].substring(0, index);
                        let word = sentence[j].substring(index + 1);
                        sent_map.push({word: word, tag: tag});
                    }
                    generate_sentence(sent_map, entities);
                }
            });
        }
    });

    update_cache();
}

function update_data() {

    $('#update_alert').modal({backdrop: 'static', keyboard: false});


    data_to_server();

    $("#cache_data").empty();

    $.ajax({
        url: url_path + 'update_to_file',
        type: 'POST',
        cache: false,
        processData: false,
        contentType: false,
        success: function () {
            data_from_server();
            get_status();
            $('#update_alert').modal('hide');

        }
    });
}

function get_status(){

    $.ajax({
        url: url_path + "get_status", type: "GET", dataType: "json", success: function (msg) {
            if (msg.status[2] === "true"){
                $('#current_status').text("  Annotating Seed");
            }else{
                $('#current_status').text("  Annotating Corpus");
            }
            $('#corpus_progress').text(msg.status[5]+" / "+msg.status[6]);
            alert(100*parseFloat(msg.status[3]).toString());
            alert(parseFloat(msg.status[4]).toString());
            $('#progress_bar_finished').css('width', (100*parseFloat(msg.status[3])/parseFloat(msg.status[4])).toString()+"%");
        }
    });
}


function getDropDown(availableOptionArray, id) {
    let result = '';
    let word_length = $("#word"+ id).outerWidth();
    result += ' <div class="dropdown-content" style="width:' + word_length + 'px">';
    availableOptionArray.forEach(function (p) {
        result += '<button onclick="tag_click(this)" class= "dropdown-content-block drop_down_button_'+ id+'" style="background-color:' + p.color + '">' + p.tag + '</button>';
    });
    result += '</div>';
    return result;
}

function getTagColor(tag, availableOptionArray) {
    let result = "";
    availableOptionArray.forEach(function (p) {
        if (p.tag === tag) {
            result = p.color;
        }
    });

    return result;
}


function update_after_seed(){

    $.ajax({
        url: url_path + 'train_and_rank_seed',
        type: 'POST',
        cache: false,
        processData: false,
        contentType: false,
        success: function(msg){
            if(msg.status) {
                update_cache();
                get_status();
                $("#seed_finish_alert").modal('hide');
                $("#after_seed_finish_alert").modal('toggle');
            }
        }
    });
}

function evaluate_inference(){

    $('#evaluate_alert').modal({backdrop: 'static', keyboard: false});

    $.ajax({
        url: url_path + 'evaluate_inference',
        type: 'POST',
        cache: false,
        processData: false,
        contentType: false,
        success: function(msg){
            if(msg.status) {
                $("#evaluate_alert").modal('hide');
                $("#after_evaluate_alert").modal('toggle');

            }
        }
    });
}

function generate_new_rank(){

    $('#rank_alert').modal({backdrop: 'static', keyboard: false});

    $.ajax({
        url: url_path + 'generate_new_rank',
        type: 'POST',
        cache: false,
        processData: false,
        contentType: false,
        success: function(msg){
            if(msg.status) {
                $("#rank_alert").modal('hide');
                $("#after_rank_alert").modal('toggle');

            }
        }
    });

}


function get_result_files(){

    $('#pills-cv-result').empty();

    // $.ajax({
    //     url: url_path+"get-cv-result", type: "GET", dataType: "json", async: false, success: function (msg) {
    //
    //     }
    // });

}

function get_gaz_files(){

    $('#pills-gaz').empty();

    $.ajax({
        url: url_path+"get_gaz", type: "GET", dataType: "json", async: false, success: function (msg) {
            for (let i=0; i<msg.files.length; i++){
                $('#pills-gaz').append('<p><a href="'+url_path+'repos/download/'+msg.files[i]+'">'+msg.files[i]+'</a></p>');
            }
        }
    });

}

function get_inf_files(){

    $('#pills-inf-result').empty();

    $.ajax({
        url: url_path+"get_inf_result", type: "GET", dataType: "json", async: false, success: function (msg) {
            for (let i=0; i<msg.files.length; i++){
                $('#pills-inf-result').append('<p><a href="'+url_path+'repos/download/'+msg.files[i]+'">'+msg.files[i]+'</a></p>');
            }
        }
    });
}
