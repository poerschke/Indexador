<?php 

include('con.php');
mysqli_select_db($con, 'sites');
?>
  <script src="vendors/Chart.js/dist/Chart.bundle.js"></script>
<script language="javascript">

var config = {
        type: 'pie',
        data: {
            datasets: [{
                data: [
<?php
  $sql = "SELECT count(id) FROM site where craw = 0";
  $res = mysqli_query($con, $sql);
  $falta = mysqli_fetch_row($res);
  $sql = "SELECT count(id) FROM site where craw = 1";
  $res = mysqli_query($con, $sql);
  $foi = mysqli_fetch_row($res);
  echo $foi[0] . ','. $falta[0];

?>],
                backgroundColor: [
                    "#46BFBD",
                    "#F7464A",
                    "#FDB45C",
                    "#949FB1",
                    "#4D5360",
                ],
                label: 'Dataset 1'
            }
            ],
            labels: ["OK", "NOK"]
        },
        options: {
            responsive: true,
            legend: {
                position: 'top',
            },
            title: {
                display: false,
                text: 'Crawling'
            },
            animation: {
                animateScale: true,
                animateRotate: true
            }
        }
    };



var config2 = {
        type: 'pie',
        data: {
            datasets: [{
                data: [<?php
  $sql = "SELECT count(id) FROM site where ip = 0";
  $res = mysqli_query($con, $sql);
  $falta = mysqli_fetch_row($res);
  $sql = "SELECT count(id) FROM site where ip !=0";
  $res = mysqli_query($con, $sql);
  $foi = mysqli_fetch_row($res);
  echo $foi[0] . ','. $falta[0];

?>],
                backgroundColor: [
                    "#46BFBD",
                    "#F7464A",
                    "#FDB45C",
                    "#949FB1",
                    "#4D5360",
                ],
                label: 'Dataset 1'
            }
            ],
            labels: [
                  "OK","NOK"
            ]
        },
        options: {
            responsive: true,
            legend: {
                position: 'top',
            },
            title: {
                display: false,
                text: 'TESTE TEXTO'
            },
            animation: {
                animateScale: true,
                animateRotate: true
            }
        }
    };



    var config3 = {
        type: 'pie',
        data: {
            datasets: [{
                data: [<?php
  $sql = "SELECT count(id) FROM ips where portscan = 0";
  $res = mysqli_query($con, $sql);
  $falta = mysqli_fetch_row($res);
  $sql = "SELECT count(id) FROM ips where portscan = 1";
  $res = mysqli_query($con, $sql);
  $foi = mysqli_fetch_row($res);
  echo $foi[0] . ','. $falta[0];

?>],
                backgroundColor: [
                    "#46BFBD",
                    "#F7464A",
                    "#FDB45C",
                    "#949FB1",
                    "#4D5360",
                ],
                label: 'Dataset 1'
            }
            ],
            labels: ["OK","NOK"]
        
  },
        options: {
            responsive: true,
            legend: {
                position: 'top',
            },
            title: {
                display: false,
                text: 'TESTE TEXTO'
            },
            animation: {
                animateScale: true,
                animateRotate: true
            }
        }
    
  
    };


    var config4 = {
        type: 'pie',
        data: {
            datasets: [{
                data: [<?php
  $sql = "SELECT count(id) FROM site where cms = 0";
  $res = mysqli_query($con, $sql);
  $falta = mysqli_fetch_row($res);
  $sql = "SELECT count(id) FROM site where cms = 1";
  $res = mysqli_query($con, $sql);
  $foi = mysqli_fetch_row($res);
  echo $foi[0] . ','. $falta[0];

?>],
                backgroundColor: [
                    "#46BFBD",
                    "#F7464A",
                    "#FDB45C",
                    "#949FB1",
                    "#4D5360",
                ],
                label: 'Dataset 1'
            }
            ],
            labels: [
                  "OK","NOK",
            ]
        },
        options: {
            responsive: true,
            legend: {
                position: 'top',
            },
            title: {
                display: false,
                text: 'TESTE TEXTO'
            },
            animation: {
                animateScale: true,
                animateRotate: true
            }
        }
    };
</script>

<script type="text/javascript">
$(function() {

                var ctx = document.getElementById("pieChart1");;
                window.myDoughnut = new Chart(ctx, config);

                var ctx2 = document.getElementById("pieChart2");;
                window.myDoughnut = new Chart(ctx2, config2);

                var ctx3 = document.getElementById("pieChart3");;
                window.myDoughnut = new Chart(ctx3, config3);

                var ctx4 = document.getElementById("pieChart4");;
                window.myDoughnut = new Chart(ctx4, config4);


});

</script>



              <div class="col-md-3 col-sm-6 col-xs-12">
                <div class="x_panel">
                  <div class="x_title">
                    <h2>Crawling</h2>
                    <ul class="nav navbar-right panel_toolbox">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                      <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>
                    </ul>
                    <div class="clearfix"></div>
                  </div>
                  <div class="x_content">
                    <canvas class="pieChart1" id="pieChart1" />
                  </div>
                </div>
              </div>





              <div class="col-md-3 col-sm-6 col-xs-12">
                <div class="x_panel">
                  <div class="x_title">
                    <h2>Resolv de IPs</h2>
                    <ul class="nav navbar-right panel_toolbox">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                      <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>
                    </ul>
                    <div class="clearfix"></div>
                  </div>
                  <div class="x_content">
                    <canvas id="pieChart2"></canvas>
                  </div>
                </div>
              </div>



              <div class="col-md-3 col-sm-6 col-xs-12">
                <div class="x_panel">
                  <div class="x_title">
                    <h2>Port Scan</h2>
                    <ul class="nav navbar-right panel_toolbox">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                      <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>
                    </ul>
                    <div class="clearfix"></div>
                  </div>
                  <div class="x_content">
                    <canvas id="pieChart3"></canvas>
                  </div>
                </div>
              </div>




              <div class="col-md-3 col-sm-6 col-xs-12">
                <div class="x_panel">
                  <div class="x_title">
                    <h2>CMS FingerPrint</h2>
                    <ul class="nav navbar-right panel_toolbox">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                      <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>
                    </ul>
                    <div class="clearfix"></div>
                  </div>
                  <div class="x_content">
                    <canvas id="pieChart4"></canvas>
                  </div>
                </div>
              </div>
