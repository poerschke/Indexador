#!/usr/bin/perl
use DBI;
use Socket;
$site_a = "a";


	my $dbh = DBI->connect('DBI:mysql:;host=localhost','user','', {'PrintError'=>1}) or die("");

while(1){
	#leep(60);
	print "[+] Buscando sites para FingerPrint de CMS\n";
	my $query = "SELECT id, url FROM sites.site WHERE ind = 0 and cms =0 order by id asc limit 5000";
	my $query_handle = $dbh->prepare($query);
    	$query_handle->execute();
 	while ( @row = $query_handle->fetchrow_array ) {
    	        $id = $row[0];
		$site = $row[1];
		if(defined($id)){
				$query = "UPDATE sites.site SET ind = 1, cms = 1 WHERE id = $id";
				$dbh->do($query);
				next if($site =~/hotelsr\.com/);
				system("perl cms.pl $id $site &");
				#
				select(undef, undef, undef, 0.5);
				print "[+][$id] Iniciando FingerPrint de CMS em: $site\n";
			
		}
		else{
			print "[+] Aguardando novos sites para FingerPrint de CMS\n";
			exit();
		}
  	}
sleep(10);
}
