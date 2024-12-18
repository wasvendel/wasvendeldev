var ownerdletter;
var letterreader;

document.onkeyup = function (data) {
    if (data.which == 27) { // Escape key
        $.post('https://wasvendel_birdmail/escape', JSON.stringify({}));
        if (letterreader == true) {
            var x = document.getElementById("p1").value;
            $.post('https://wasvendel_birdmail/updating', JSON.stringify({ text: x}));
            $("#main").fadeOut();
            $("#main").css('display', 'none');
            letterreader = false;
            document.getElementById("p1").value = "";
        }else {
            ownerdletter = document.getElementById("p1").value;
            $("#main").fadeOut();
            $("#main").css('display', 'none');
        }
    }
};

window.addEventListener('message', function(e) {
    switch(event.data.action) {
        case 'openLetterRead':
        letterreader = true;
        $("textarea").attr('disabled','disabled');
        $("button").hide();
        $("#main").fadeIn();
        document.getElementById("p1").value = event.data.TextRead;
        break;
    }
});

