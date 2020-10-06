<?php

$ip = mysqli_real_escape_string($con, $_GET['id']);
mysqli_select_db($con, 'sites');



$sql = "SELECT id FROM ips WHERE ip = '$ip'";
$q = mysqli_query($con, $sql);
$res = mysqli_fetch_array($q, MYSQLI_BOTH);

$ip_id = $res['id'];




$sql = "SELECT COUNT(url) AS qtd FROM site WHERE ip = $ip_id";
$q = mysqli_query($con, $sql);
$res = mysqli_fetch_array($q, MYSQLI_BOTH);

$sql2 = "SELECT webserver FROM webserver WHERE ip_id = $ip_id";
$q2 = mysqli_query($con, $sql2);
$res2 = mysqli_fetch_array($q2, MYSQLI_BOTH);

$sql3 = "SELECT DISTINCT(porta) FROM portscan WHERE ip_id = $ip_id ORDER BY porta ASC";
$q3 = mysqli_query($con, $sql3);

$sql4 = "SELECT * FROM site WHERE ip = $ip_id ORDER BY id ASC";
$q4 =mysqli_query($con, $sql4);

?>


<div class="right_col" role="main">
          <div class="">



            <div class="row">
              <div class="col-md-12 col-xs-12">
                <div class="x_panel">
                  <div class="x_title">
                        <p><label>IP Address:</label> <?php echo $ip; ?></p>
                        <p><label>Sites hospedados neste IP:</label> <?php echo $res['qtd']; ?></p>
                        <p><label>Web Server:</label> <?php echo $res2['webserver']; ?></p>
                        <p><label>Open Ports:</label> <ol type="1"><?php
                        	while($res3 = mysqli_fetch_array($q3, MYSQLI_BOTH)){
                        		echo "<li>".$res3['porta'] ."/TCP Open</li>\n";
                        	}
                        ?></ol></p>

                    <div class="clearfix"></div>
                  </div>

                  <div class="x_content">
                  <p><label>Sites hospedados neste IP:</label> </p>
                  <ol type="1">
					<?php
                        	while($res4 = mysqli_fetch_array($q4, MYSQLI_BOTH)){
                        		echo "<li><a href='index.php?page=url&id=".$res4['id'] ."'>".$res4['url'] ."</a></li>\n";
                        	}
                        ?>                  	

                  </ol>

</div></div></div></div></div></div>

