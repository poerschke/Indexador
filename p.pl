#!/usr/bin/perl
use DBI;

my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>0}) or die("");




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

