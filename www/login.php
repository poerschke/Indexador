<?php

if(strtoupper($_SERVER['REQUEST_METHOD']) === "POST"){

	include('con.php');
	mysqli_select_db($con, 'sites');
	$user = mysqli_real_escape_string($con, $_POST['user']);
	$senha = md5($_POST['pass']);

	$sql = "SELECT * FROM usuarios WHERE username = '$user' AND senha = '$senha'";

	$q = mysqli_query($con, $sql);
	$res = mysqli_fetch_array($q, MYSQLI_BOTH);

	if(isset($res['id'])){
        // faz sessao
		session_start();
		$_SESSION['logado_lab']	=       1;
		$_SESSION['id']        	=       $res['id'];
		$_SESSION['user']    	=       $res['username'] ;
		$_SESSION['nome']    	=       $res['nome'];
		$_SESSION['senha']   	=       $res['senha'];
		$_SESSION['foto']   	=       $res['foto'];
		$_SESSION['email']	= 	$res['email'];
		$_SESSION['ramal']	= 	$res['ramal'];
		$_SESSION['celular']	= 	$res['celular'];

		header('Location: index.php');
	}
	else{
		header('Location: login.php');
	}
}
else {

?>


<!DOCTYPE html>
<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Login Indexador </title>

    <!-- Bootstrap -->
    <link href="vendors/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="vendors/font-awesome/css/font-awesome.min.css" rel="stylesheet">
    <!-- NProgress -->
    <link href="vendors/nprogress/nprogress.css" rel="stylesheet">
    <!-- Animate.css -->
    <link href="vendors/animate.css/animate.min.css" rel="stylesheet">

    <!-- Custom Theme Style -->
    <link href="build/css/custom.min.css" rel="stylesheet">
  </head>

  <body class="login">
<?php 
?>
    <div>
      <div class="login_wrapper">
        <div class="animate form login_form">
          <section class="login_content">
            <form action="login.php" method="POST">
              <h1>Login</h1>
              <div>
                <input type="text" class="form-control" placeholder="Usu&aacute;rio" name="user" required />
              </div>
              <div>
                <input type="password" class="form-control" placeholder="Senha" name="pass" required/>
              </div>
              <div>
                <input type="submit" class="btn btn-default submit" value="Entrar">
              </div>
              <div class="clearfix"></div>
              <div class="separator">
                <div class="clearfix"></div>
                <br />
                <div>
                  <h1><i class="fa fa-bug"></i> Painel de Controle</h1>
                </div>
              </div>
            </form>
          </section>
        </div>

      </div>
    </div>
  </body>
</html>
<?php        
}
?>
