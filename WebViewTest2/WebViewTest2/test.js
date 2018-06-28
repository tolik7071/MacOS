function getColorFor(element) {
   return element.style.background == 'red' ? 'yellow' : 'red';
}

function onClick(sender) {
   sender.style.background = getColorFor(sender);
}
