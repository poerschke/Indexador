                  <?php
include('con.php');
mysqli_select_db($con, 'sites');
    
                  $sql = "SELECT sum(a.total) FROM (SELECT count(id) AS total FROM site WHERE ip IS NOT NULL GROUP BY ip ORDER BY count(id) DESC LIMIT 10) a";
                  $res = mysqli_query($con, $sql);
                  $total = mysqli_fetch_row($res);

                  $sql = "SELECT ip, count(id) as total FROM site WHERE ip IS NOT NULL GROUP BY ip ORDER BY count(id) DESC LIMIT 10";
                  $res = mysqli_query($con, $sql);


                  while($ar = mysqli_fetch_array($res)){
                    $per = $ar['total'] / $total[0] * 100;
                    ?>
                  <div class="widget_summary">
                    <div class="w_left w_25">
                      <span><?php echo $ar['ip']; ?></span>
                    </div>
                    <div class="w_center w_55">
                      <div class="progress">
                        <div class="progress-bar bg-green" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: <?php echo $per; ?>%;">
                          <span class="sr-only"><?php echo $per; ?>%</span>
                        </div>
                      </div>
                    </div>
                    <div class="w_right w_25">
                      <span><?php echo $ar['total']; ?> Sites</span>
                    </div>
                    <div class="clearfix"></div>
                  </div>


                    <?php

                  }

                  ?>
