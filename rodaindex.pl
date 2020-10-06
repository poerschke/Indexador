#!/usr/bin/perl
use DBI;
use Socket;
$site_a = "a";

	my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>1}) or die("");

while(1){
	print "Buscando\n";
	my $query = "SELECT id, url FROM `sites`.`site` WHERE ind2 = 0 and ip is not NULL and ip != '' order by id ASC limit 50";
#	my $query = "select id, site from `sites`.`site` WHERE ip IS NOT NULL AND pagina is NULL AND IP != '' order by id asc limit 1000";
	my $query_handle = $dbh->prepare($query);
    	$query_handle->execute();
 	while ( @row = $query_handle->fetchrow_array ) {
    	        $id = $row[0];
		$site = $row[1];
		if(defined($id)){
				$query = "UPDATE `sites`.`site` SET ind2 = 1 WHERE id = $id";
				$dbh->do($query);
				system("perl index.pl $id $site &");
				select(undef, undef, undef, 0.3);
			
		}
		else{
			print "Aguardando\n";
			sleep(20);
		}
  	}
sleep(30);
}
