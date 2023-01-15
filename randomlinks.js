<script>
	start();
	function start(){
	markanddanah ("meme.html", "astiwere.html", 
	"autobio.html"[...]);

}
function markanddanah(){
var argv=markanddanah.arguments;
var argc=argv.length;
var num=Math.floor(Math.random()*argc);
document.write("<A HREF=", argv[num],">");
return argv[0];


}
</script>