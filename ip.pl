#!/usr/bin/perl
use DBI;
use Socket;


my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>0}) or die("");

while(1){
	print "[+] Buscando dominios para resolver IP\n";
	my $query = "SELECT id, url FROM `sites`.`site` WHERE ip = 0 ORDER BY id ASC limit 100";
	my $query_handle = $dbh->prepare($query);
    $query_handle->execute();
	$x =0;
 	while ( @row = $query_handle->fetchrow_array ) {
	$x++;
    	$id = $row[0];
		$site = $row[1];
		if(defined($id)){
			$ip = "";
			$ip = join(".", unpack("C4", (gethostbyname($site))[4]));
			if(length($ip) > 6){

				$query = "INSERT INTO sites.ips(ip) VALUES('$ip')";
				$dbh->do($query);

				$query = "SELECT id FROM sites.ips WHERE sites.ips.ip = '$ip'";
				my $handle = $dbh->prepare($query);
				$handle->execute();
				@ro = $handle->fetchrow_array;
				$id_ip = $ro[0];
				$query = "UPDATE `sites`.`site` SET ip = $id_ip WHERE id = $id";
				$dbh->do($query);
			}
			else{
				$query = "update `sites`.`site` set ip = -1  WHERE id = $id";
				$dbh->do($query);	
			}
			print "[+][$id] Site: $site IP: $ip\n";

		}
		else{
			print "[+] Aguardando novos dominios na base\n";
			sleep(30);
		}
  	}
if($x == 0){
	print "[+] Aguardando novos dominios na base\n";
	sleep(30);
}

}
