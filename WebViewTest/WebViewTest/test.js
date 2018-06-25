function show_hi() {
   alert('HI!');
}

function get_string() {
   return "Hi All!";
}

function send_message() {
   window.webkit.messageHandlers.observe.postMessage('some_message');
}

function send_current_date_time() {
    window.FTM.callme();
}

//window.FTM.Browse = function(e) {
//   window.webkit.messageHandlers.browse.postMessage(e);
//}

function change_color() {
    document.getElementById('color_changeble').style.backgroundColor = 'red';
}
