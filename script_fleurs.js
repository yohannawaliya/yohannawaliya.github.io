var video = document.getElementById("mp4");
var spinner = document.getElementById("spinner");
var delayMillis = 4000;
var spinnerIsHere = 1;
video.volume = 0;

var playVid = setTimeout(function() {
  if(spinnerIsHere == 1) {
    // Delete element DOM
    // spinner.parentNode.removeChild(spinner);
    spinner.style.visibility = "hidden";
    spinnerIsHere = 0;
  }
  video.play();
}, delayMillis);

video.addEventListener("click", function( event ) {
  if(video.paused) {
    if(spinnerIsHere == 1) {
      // Delete element DOM
      // spinner.parentNode.removeChild(spinner);
      spinner.style.visibility = "hidden";
      spinnerIsHere = 0;
    }
    clearTimeout(playVid);
    video.play();
  } else {
    video.pause();
    if(spinnerIsHere == 0) {
      spinner.style.visibility = "visible";
      spinnerIsHere = 1;
    }
  }
}, false);