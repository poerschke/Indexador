                  <table class="" style="width:100%">
                    <tr>
                      <td>
                        <table class="tile_info">
                          <tr><th>Site</th><th>#id</th><th>IP</th></tr>

<?php
  include('con.php');
  mysqli_select_db($con, 'sites');
  $sql = "SELECT url, id, i.ip FROM site s left join ips i on i.id = s.ip ORDER BY id DESC LIMIT 10";
  $res = mysqli_query($con, $sql);
  while($resp = mysqli_fetch_array($res)){
    echo "<tr><td><p><i class='fa fa-cloud blue'></i>". $resp['url'] ."</p></td><td>". $resp['id'] ."</td><td>". $resp['ip'] ."</td> </tr>";

  }

?>
  
                        </table>
                      </td>
                    </tr>
                  </table>
