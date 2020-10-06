#!/usr/bin/perl
use DBI;

my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>0}) or die("");

	@ips = ();
	$x=0;
	print "[+] Buscando IP para rodar portscan\n";
	my $query = "SELECT id, ip  FROM sites.ips WHERE portscan = 0";
	my $query_handle = $dbh->prepare($query);
    $query_handle->execute();
 	while ( @row = $query_handle->fetchrow_array ) {
    	$id = $row[0];
		$ip = $row[1];
		push(@ids, $id);

		if(defined($ip)){
			system("nmap -F --host-timeout=600 -Pn -oX ./portscan/".$id.".xml --open -sS $ip &");
            select(undef, undef, undef, 0.1);
		}
		else{
			print "[+] Aguardando novos IPs na base\n";
			sleep(30);
		}
	}
exit;
	sleep(180);



	opendir(dir, './portscan/');
	@arquivos = readdir(dir);
	closedir(dir);
	sleep(1);

	foreach $arq (@arquivos){
		next if($arq =~/^\.$|^\.\.$/);
		$re = `cat ./portscan/$arq; rm ./portscan/$arq`;
		($id, $ext) = split(/\./, $arq);
			while($re =~m/<port protocol="tcp" portid="([0-9]+)">/gi){
				$porta = $1;
				$sql = "INSERT INTO sites.portscan(ip_id, porta) VALUES('$id', $porta)";
				$dbh->do($sql);
			}
            $query = "UPDATE `sites`.`ips` SET portscan = 1  WHERE id = $id";
            $dbh->do($query);

	}

