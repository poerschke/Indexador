<?php
$id = (int) $_GET['id'];
mysqli_select_db($con, 'sites');





$sql = "SELECT s.id, s.url, c.cms, i.id as ip_id, i.ip, w.webserver FROM site s 
left join cms c on c.site_id = s.id
left join ips i on s.ip = i.id
left join webserver w on w.ip_id = i.id
WHERE s.id = $id";



$q = mysqli_query($con, $sql);
$res = mysqli_fetch_array($q, MYSQLI_BOTH);

?>


<div class="right_col" role="main">
          <div class="">

            <div class="page-title">
              <div class="title_left">
              </div>
            </div>
            <div class="clearfix"></div>


            <div class="row">
              <div class="col-md-12 col-xs-12">
                <div class="x_panel">
                  <div class="x_title">
                        <p><label>Dom&iacute;nio:</label> <a href="http://<?php echo $res['url']; ?>" target="_blank"><?php echo $res['url']; ?></a></p>
                        <p><label>IP Address:</label> <a href="index.php?page=ip&id=<?php echo $res['ip']; ?>" target="_blank"><?php echo $res['ip']; ?></a></p>
                        <p><label>CMS:</label> <?php echo $res['cms']; ?></p>
                        <p><label>Web Server:</label> <?php echo $res['webserver']; ?></p>
                        <p><label>Open Ports:</label> <ul><?php
                        $sql = "SELECT * FROM portscan WHERE ip_id = ". $res['ip_id']; 
                        $q5 = mysqli_query($con, $sql);
							           while($res5 = mysqli_fetch_array($q5, MYSQLI_BOTH)){
								echo "<li>".$res5['porta'] ."/TCP Open</li>\n";
							}



                         ?></ul></p>


                    <div class="clearfix"></div>
                  </div>

                  <div class="x_content">

			<p><label>Links explor&aacute;veis:</label></p>
			<ol type="1">
				<?php
          $sql = "SELECT * FROM link WHERE site_id = ". $res['id'];
          $q3 = mysqli_query($con,$sql);
					while($res3 = mysqli_fetch_array($q3, MYSQLI_BOTH)){
						echo "<li><a href='".$res3['link']."' target='_blank'>".$res3['link'] ."</a></li>\n";
					}
				?>

			</ol>

</div></div></div></div></div></div>

