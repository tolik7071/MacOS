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
   window.webkit.messageHandlers.observe.postMessage(Date());
}
