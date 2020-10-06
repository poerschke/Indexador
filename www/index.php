<?php
			include_once('funcoes.php');
			
			$page = $_GET['page'];
			$sub1 = $_GET['sub1'];
			// cabeçalho
			include('header.php');
			
			//<!-- sidebar menu -->
			include('menu.php');
			//<!-- /sidebar menu -->
			
			//<!-- top navigation -->
			include('top.php');
			//<!-- /top navigation -->

			//<!-- page content -->
			switch($page){
			
				case 'dashboard':
					include('dashboard.php');
					break;

				case 'perfil':
					switch($sub1){
						case 'senha':
							include('perfil_senha.php');
							break;

						case 'email':
							include('perfil_email.php');
							break;

						case 'ramal';
							include('perfil_ramal.php');
							break;

						case 'celular':
							include('perfil_celular.php');
							break;

						default:
							include('perfil.php');
							break;
						}
					break;
						
					case 'pesquisar':
							include('pesquisa.php');
							break;
					case 'url':
							include('url.php');
							break;
					case 'ip':
							include('ip.php');
							break;
					
				default:
					include('dashboard.php');
			}
			
			//<!-- /page content -->
				
			// <!-- footer content -->
			include('footer.php');

?>
