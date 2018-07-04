function getColorFor(element) {
    return element ? (element.style.backgroundColor == 'red' ? 'yellow' : 'red') : 'blue';
}

function onClick(sender) {
   document.getElementById('my_div').style.backgroundColor = getColorFor(sender);
}

function setDivColor() {
    document.getElementById('my_div').style.backgroundColor = 'blue';
}
