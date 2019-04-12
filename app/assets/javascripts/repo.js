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



let uploadTagArray = [];
let availableOptionArray = [];
let color_list = ["#ffffff","#7FDBFF","#0074D9","#FF851B"];

$(document).ready(function () {
    data_from_server();
    update_cache();
});

function data_from_server(){
    $.ajax({
        url: "get_sentence", type: "GET", dataType: "json", success: function (msg) {
            generate_sentence(msg.sentence[0], msg.sentence[1]);
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
        let tempBlock = '<div class="dropdown">' + tempSpan + getDropDown(availableOptionArray, i.toString()) + '</div>';
        $("#sentence_block").append(tempBlock);
    }
}


function send_data() {
    data_to_server();

    data_from_server();

    update_cache();
}


function data_to_server(){

    let jsonArrayStr="";
    uploadTagArray.forEach(function (element){
        jsonArrayStr += JSON.stringify(element) + " "
    });
    $.ajax({
        url: "send_sentence.json",
        type: "POST",
        data: jsonArrayStr,
        async: false,
        success: function () {
            alert("send!!!!!");
        }
    });
}


function update_cache(){
    $.ajax({
        url: "get_cache_data", type: "GET", dataType: "json", success: function (msg) {
            generate_cache_sentence(msg.sentence)
        }
    });
}


function generate_cache_sentence(sentence){

    $("#cache_block").empty();

    for (let i=0; i<sentence.length; i++){
        let str_div = '<div id="cache'+i.toString()+'" onclick="cache_to_annotate(this)">';


        for (let j=0; j<sentence[i].length;j++){
            let index = 0;
            while (sentence[i][j][index] !== "\t"){
                index += 1;
            }
            let tag = sentence[i][j].substring(0,index);
            let word = sentence[i][j].substring(index+1) + "";
            let tempSpan = '<span style="background-color:' + getTagColor(tag, availableOptionArray)
                + '"' + ' class ="word" id = "words' + i.toString() + '">' + word + '</span>';
            str_div += tempSpan;
        }
        str_div += '</div>';
        $("#cache_block").append(str_div);
    }
}





function tag_click(tagButton) {
    uploadTagArray[parseInt(tagButton.className)].tag = tagButton.innerHTML;
    $("#word" + tagButton.className).css("background-color", getTagColor(tagButton.innerHTML, availableOptionArray));
}


function cache_to_annotate(sentence_div) {

    data_to_server();


    $.ajax({
        url: 'send_annotating_cache',
        type: 'POST',
        data: parseInt(sentence_div.id.substring(5)),
        cache: false,
        processData: false,
        contentType: false,
        async: false
    });

    $.ajax({
        url: "get_cache_sentence", type: "GET", dataType: "json", async: false, success: function (msg) {
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
    update_cache();
}

function update_data(){

    data_to_server();
    $("#cache_block").empty();

    $.ajax({
        url: 'update_to_file',
        type: 'POST',
        cache: false,
        processData: false,
        contentType: false
    });
    data_from_server();
    get_status();
}

function get_status(){

    $.ajax({
        url: "get_status", type: "GET", dataType: "json", success: function (msg) {
            if (msg.sentence[0]){
                document.getElementById('annotating_status').innerHTML = "Annotating Seed";
            }else{
                document.getElementById('annotating_status').innerHTML = "Annotating Corpus";
            }
            document.getElementById('seed_status').innerHTML = msg.sentence[1].toString() + "/" + msg.sentence[2].toString();
            document.getElementById('corpus_status').innerHTML = msg.sentence[3].toString() + "/" + msg.sentence[4].toString();
        }
    });
}



function getDropDown(availableOptionArray, id) {
    let result = '';
    result += ' <div class="dropdown-content">';
    availableOptionArray.forEach(function (p) {
        result += '<button class="' + id.toString() +
            '" onclick="tag_click(this)" class= "dropdown-content-block" style="background-color:' + p.color + '">' + p.tag + '</button>';
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







function update_rank(){
    $.ajax({
        url: 'feature_engineering_and_train',
        type: 'POST',
        cache: false,
        processData: false,
        contentType: false
    });
}