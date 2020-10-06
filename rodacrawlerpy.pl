#!/usr/bin/perl
use DBI;
use Socket;
$site_a = "a";
#alarm(300);
	my $dbh = DBI->connect('DBI:mysql:;host=localhost','user','', {'PrintError'=>1}) or die("");

while(1){
	$x=0;
	#	print "[+] Buscando sites para iniciar o crawling\n";
	my $query = "SELECT id, url FROM `sites`.`site` WHERE craw = 0 and url like '%.br' ORDER BY id DESC LIMIT 10000";
#	my $query = "select id, site from `sites`.`site` WHERE ip IS NOT NULL AND pagina is NULL AND IP != '' order by id asc limit 1000";
	my $query_handle = $dbh->prepare($query);
    	$query_handle->execute();
 	while ( @row = $query_handle->fetchrow_array ) {
    	$x++;
    	$id = $row[0];
		$site = $row[1];
		$y = `ps aux |grep python |grep -v grep |wc -l`;
		chomp($y);
		while($y > 50){
			sleep(1);
			$y = `ps aux |grep python |grep -v grep |wc -l`;
			chomp($y);
		}

		if(defined($id)){
				$query = "UPDATE `sites`.`site` SET craw = 1 WHERE id = $id";
				$dbh->do($query);
				system("python crawler.py $site &");
				print "[$x] [$id] Buscando $site\n";
				#select(undef, undef, undef, 0.1);
				#		print "[+][$x][$id] Crawler iniciado em $site\n";
			
		}
		else{
			print "[+] Aguardando novos sites no banco de dados\n";
			sleep(5);
			$x=0;
		}
  	}
sleep(30);
}
