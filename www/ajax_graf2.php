<?php 

include('con.php');
mysqli_select_db($con, 'sites');
?>
  <script src="vendors/Chart.js/dist/Chart.bundle.js"></script>
<script language="javascript">

var config5 = {
        type: 'pie',
        data: {
            datasets: [{
                data: [
<?php
  $sql = "SELECT count(id) FROM ips where webserver = 0";
  $res = mysqli_query($con, $sql);
  $falta = mysqli_fetch_row($res);
  $sql = "SELECT count(id) FROM ips where webserver = 1";
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





</script>

<script type="text/javascript">
$(function() {

                var ctx5 = document.getElementById("pieChart5");;
                window.myDoughnut = new Chart(ctx5, config5);


});

</script>



              <div class="col-md-3 col-sm-6 col-xs-12">
                <div class="x_panel">
                  <div class="x_title">
                    <h2>WebServer FingerPrint</h2>
                    <ul class="nav navbar-right panel_toolbox">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                      <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>
                    </ul>
                    <div class="clearfix"></div>
                  </div>
                  <div class="x_content">
                    <canvas class="pieChart1" id="pieChart5" />
                  </div>
                </div>
              </div>



