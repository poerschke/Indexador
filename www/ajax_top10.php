                  <table class="" style="width:100%">
                    <tr>
                      <td>
                        <table class="tile_info">
                          <tr><th>IP</th><th>%</th><th>SITES</th></tr>


                  <?php
include('con.php');
mysqli_select_db($con, 'sites');
    
                  $sql = "SELECT sum(a.total) FROM (SELECT count(id) AS total FROM site WHERE ip IS NOT NULL GROUP BY ip ORDER BY count(id) DESC LIMIT 10) a";
                  $res = mysqli_query($con, $sql);
                  $total = mysqli_fetch_row($res);

                  $sql = "SELECT i.ip, count(s.id) as total FROM site s left join ips i on i.id = s.ip WHERE s.ip IS NOT NULL GROUP BY s.ip ORDER BY count(id) DESC LIMIT 10";
                  $res = mysqli_query($con, $sql);







                  while($ar = mysqli_fetch_array($res)){
                    $per = $ar['total'] / $total[0] * 100;

                    echo "<tr><td><p><i class='fa fa-cloud blue'></i><a href='index.php?page=ip&id=". $ar['ip'] ."'>". $ar['ip'] ."</p></td><td>". number_format($per, 2, ',', '.') ."%</td><td>".  number_format($ar['total'], 0, '', '.') ."</td> </tr>";

                  }

                  ?>
                        </table>
                      </td>
                    </tr>
                  </table>