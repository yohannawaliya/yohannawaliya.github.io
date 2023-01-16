$(".wrapper li").on("click", function() {
  var index = $(this).index() + 1;
  $(".wrapper")[0].className = $(".wrapper")[0].className.replace(/\brotated-\d+\b/g, '');
  $(".wrapper").addClass("rotated-" + index);
});