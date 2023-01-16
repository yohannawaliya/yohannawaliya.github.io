$(window).scroll(function(){
  var wScroll= $(this).scrollTop();
 var pScroll= $('.climatopix').offset().top;
  if(wScroll>pScroll)
    $('.container').css('position',"fixed");
  else 
    $('.container').css('position',"absolute");
  var dScroll= wScroll-$('.textls').offset().top;
  if(dScroll<0)
    $('.container').css('position',"absolute");
  else  
    if(dScroll>800)
    {   
      $('.container').css('position',"absolute");
      $('.container').css('top',"800px");
    }
    else{
      $('.container').css('position',"fixed")
      $('.container').css('top', "0px");
      if(0<dScroll&&dScroll<200)
        $('.imgLs').css('transform','translateY(0px)')
      if(200<dScroll&&dScroll<600)
        $('.imgLs').css('transform','translateY(-400px)')
      if(600<dScroll&&dScroll<800)
        $('.imgLs').css('transform','translateY(-800px)')
    }
  
});
