<?php
include('con.php');
include('funcoes.php');
$valor = mysqli_real_escape_string($con, $_GET['valor']);
mysqli_select_db($con, 'sites');



if((strpos(strtolower($valor), 'site:') !== false) or (strpos(strtolower($valor), 'webserver:') !== false) or (strpos(strtolower($valor), 'cms:') !== false) or (strpos(strtolower($valor), 'port:') !== false) or (strpos(strtolower($valor), 'inurl:') !== false)){
	$dados = explode(':', $valor);
	$dados[1] = ltrim($dados[1]);


	switch ($dados[0]) {
		case 'site':
			$sql = "SELECT s.id, s.url, i.ip FROM site s left join ips i on i.id = s.ip WHERE url LIKE '%$dados[1]%' ORDER BY ip ASC";
			$q = mysqli_query($con, $sql);
			echo '<table class="tile_info" style="font-size: 13px;font-weight: 400;"><thead><tr><th>#ID</th><th>IP</th><th>URL</th></tr></thead>';
			while($res = mysqli_fetch_array($q, MYSQLI_BOTH)){
				echo "<tr><td>".$res['id']."</td><td><a href='/index.php?page=ip&id=".$res['ip']."'>".$res['ip']."</a></td><td><a href='/index.php?page=url&id=".$res['id']."'>".$res['url'] ."</a></td></tr>\n";
			}
			echo '</table>';

			break;


		case 'webserver':
			$sql = "SELECT i.ip, w.webserver FROM webserver w left join ips i on i.id = w.ip_id WHERE w.webserver LIKE '%$dados[1]%' ORDER BY i.ip ASC";
			$q = mysqli_query($con, $sql);
			echo '<table class="tile_info" style="font-size: 13px;font-weight: 400;"><thead><tr><th>IP</th><th>WebServer</th></tr></thead>';
			while($res = mysqli_fetch_array($q, MYSQLI_BOTH)){
				echo "<tr><td><a href='/index.php?page=ip&id=".$res['ip']."'>".$res['ip']."</a></td><td>".$res['webserver'] ."</td></tr>\n";
			}
			echo '</table>';

			break;		
			

		case 'cms':
			$sql = "SELECT c.cms, s.url, i.ip, c.site_id FROM cms c LEFT JOIN site s ON  s.id = c.site_id LEFT JOIN ips i on i.id = s.ip WHERE c.cms LIKE '%$dados[1]%' ORDER BY s.ip ASC";
			$q = mysqli_query($con, $sql);
			echo '<table class="tile_info" style="font-size: 13px;font-weight: 400;"><thead><tr><th>CMS</th><th>IP</th><th>Site</th></tr></thead>';
			while($res = mysqli_fetch_array($q, MYSQLI_BOTH)){
				echo "<tr><td>".$res['cms']."</td><td><a href='/index.php?page=ip&id=".$res['ip']."'>".$res['ip']."</a></td><td><a href='/index.php?page=url&id=".$res['site_id']."'>".$res['url'] ."</a></td></tr>\n";
			}
			echo '</table>';
			break;

		case 'port':
			$sql = "SELECT i.ip, p.porta FROM portscan p left join ips i on i.id = p.ip_id WHERE p.porta = ". $dados[1] . " ORDER BY ip ASC";
			$q = mysqli_query($con, $sql);
			echo '<table class="tile_info" style="font-size: 13px;font-weight: 400;"><thead><tr><th>IP</th><th>Porta</th></tr></thead>';
			while($res = mysqli_fetch_array($q, MYSQLI_BOTH)){
				echo "<tr><td><a href='/index.php?page=ip&id=".$res['ip']."'>".$res['ip']."</a></td><td>".$res['porta'] ." open</td></tr>\n";
			}
			echo '</table>';
			break;

		case 'inurl':
			$sql = "SELECT l.site_id, l.link, s.url, i.ip FROM link l LEFT JOIN site s ON s.id = l.site_id left join ips i on s.ip = i.id WHERE link LIKE '%$dados[1]%' ORDER BY s.ip ASC";
			$q = mysqli_query($con, $sql);
			echo '<table class="tile_info" style="font-size: 13px;font-weight: 400;"><thead><tr><th>IP</th><th>Site</th><th>Link</th></tr></thead>';
			while($res = mysqli_fetch_array($q, MYSQLI_BOTH)){
				echo "<tr><td><a href='/index.php?page=ip&id=".$res['ip']."'>".$res['ip']."</a></td><td><a href='/index.php?page=url&id=".$res['site_id']."'>".$res['url'] ."</a></td><td><a href='". $res['link'] ."' target='_blank'>". $res['link']."</a></td></tr>\n";
			}
			echo '</table>';
			break;

	}


}





else{


$sql = "SELECT s.id, s.url, i.ip FROM site s left join ips i on s.ip = i.id WHERE i.ip like '%$valor%' or s.url like '%$valor%'";

$q = mysqli_query($con, $sql);
?>

                        <table class="tile_info" style="font-size: 13px;font-weight: 400;"><thead><tr><th>#ID</th><th>IP</th><th>URL</th></tr></thead>

<?php
	while($res = mysqli_fetch_array($q, MYSQLI_BOTH)){

		echo "<tr><td>".$res['id']."</td><td><a href='/index.php?page=ip&id=".$res['id']."'>".$res['ip']."</a></td><td><a href='/index.php?page=url&id=".$res['id']."'>".$res['url'] ."</a></td></tr>\n";
	}

echo '</table>';

}
?>



