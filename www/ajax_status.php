  <?php

  include('con.php');



            mysqli_select_db($con, 'sites');

            $sql = "SELECT count(id) FROM site";
            $res = mysqli_query($con, $sql);
            $site_base = mysqli_fetch_row($res);

            $sql = "SELECT count(id) FROM ips";
            $res = mysqli_query($con, $sql);
            $ips_base = mysqli_fetch_row($res);


            $sql = "SELECT count(id) FROM site WHERE ip !=0";
            $res = mysqli_query($con, $sql);
            $ip_res = mysqli_fetch_row($res);

            $sql = "SELECT count(id) FROM ips WHERE portscan = 1";
            $res = mysqli_query($con, $sql);
            $jexc = mysqli_fetch_row($res);

            $sql = "SELECT count(id) FROM ips WHERE webserver = 1";
            $res = mysqli_query($con, $sql);
            $web = mysqli_fetch_row($res);            

            $sql = "SELECT count(id) FROM site WHERE cms = 1";
            $res = mysqli_query($con, $sql);
            $shellc = mysqli_fetch_row($res);


            $sql = "SELECT count(id) FROM site WHERE craw = 0";
            $res = mysqli_query($con, $sql);
            $crawc = mysqli_fetch_row($res);

            $inst = `ps aux |grep perl |grep -v grep |wc -l`;

?>
              <div class="col-md-2 col-sm-4 col-xs-6 tile_stats_count">
              <span class="count_top"><i class="fa fa-sitemap"></i> Sites na base</span>
              <div class="count" align='center'><?php echo number_format($site_base[0],0, '', '.');  ?></div>
              <span class="count_bottom"><i class="green"><i class="fa fa-sort-asc"></i> <?php echo number_format($site_base[0]/5000000*100, 3, ',', '.'); ?>% da meta</i></span>
            </div>

            <div class="col-md-2 col-sm-4 col-xs-6 tile_stats_count">
              <span class="count_top"><i class="fa fa-sitemap"></i> Sites com IP resolvido</span>
              <div class="count" align='center'><?php echo number_format($ip_res[0],0, '', '.'); ?></div>
              <span class="count_bottom"><i class="green"><i class="fa fa-sort-asc"></i><?php echo number_format($ip_res[0]/$site_base[0]*100, 3, ',', '.'); ?>% Completos </i></span>
            </div>
            <div class="col-md-2 col-sm-4 col-xs-6 tile_stats_count">
              <span class="count_top"><i class="fa fa-sitemap"></i> PortScan</span>
              <div class="count" align='center'><?php echo number_format($jexc[0],0, '', '.'); ?></div>
              <span class="count_bottom"><i class="green"><i class="fa fa-sort-asc"></i><?php echo number_format($jexc[0]/$ips_base[0]*100, 3, ',','.'); ?>% Completos </i></span>
            </div>
            <div class="col-md-2 col-sm-4 col-xs-6 tile_stats_count">
              <span class="count_top"><i class="fa fa-sitemap"></i> CMS Fingerprint / Index links</span>
              <div class="count" align='center'><?php echo number_format($shellc[0],0, '', '.'); ?></div>
              <span class="count_bottom"><i class="green"><i class="fa fa-sort-asc"></i><?php echo number_format($shellc[0]/$site_base[0]*100, 3, ',','.'); ?>% Completos </i></span>
            </div>
            <?php
            /*
            <div class="col-md-2 col-sm-4 col-xs-6 tile_stats_count">
              <span class="count_top"><i class="fa fa-sitemap"></i> Sites aguardando crawling</span>
              <div class="count" align='center'><?php echo number_format($crawc[0],0, '', '.'); ?></div>
              <span class="count_bottom"><i class="green"><i class="fa fa-sort-asc"></i><?php echo number_format(100 - $crawc[0]/$site_base[0]*100, 2, ',','.'); ?>% Completos </i></span>
            </div>
*/?>

            <div class="col-md-2 col-sm-4 col-xs-6 tile_stats_count">
              <span class="count_top"><i class="fa fa-sitemap"></i> WebServer FingerPrint</span>
              <div class="count" align='center'><?php echo number_format($web[0],0, '', '.'); ?></div>
              <span class="count_bottom"><i class="green"><i class="fa fa-sort-asc"></i><?php echo number_format($web[0]/$ips_base[0]*100, 3, ',','.'); ?>% Completos </i></span>
            </div>

            <div class="col-md-2 col-sm-4 col-xs-6 tile_stats_count">
              <span class="count_top"><i class="fa fa-sitemap"></i> Instancias rodando</span>
              <div class="count" align='center'><?php echo $inst; ?></div>
              <span class="count_bottom"><i class="green">Processos</i></span>
            </div>

            