
<script src="js/ajax.js"></script>
<script>
function pesquisa_destaque(valor)
{
//FUNÇO QUE MONTA A URL E CHAMA A FUNÇO AJAX
url="busca.php?valor="+valor;
ajax(url);
}
</script>

<div class="right_col" role="main">
          <div class="">

            <div class="page-title">
              <div class="title_left">
		<h3>Pesquisar</h3>
              </div>
            </div>
            <div class="clearfix"></div>


            <div class="row">
              <div class="col-md-12 col-xs-12">
                <div class="x_panel">
                  <div class="x_title">
                        <label for="idDestaque1">Buscar por:</label> <input name="idDestaque1" id="idDestaque1" type="text" onblur="pesquisa_destaque(this.value)" value=""/> <span>EX: site:site.com, webserver:apache, cms: wordpress, port: 80, inurl:/index.php?id= </span>

                    <div class="clearfix"></div>
                  </div>

                  <div class="x_content">

			<div id="resposta"></div>

</div></div></div></div></div></div>




