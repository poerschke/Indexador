#!/usr/bin/perl
use DBI;



my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>1}) or die("");
		$ip = $ARGV[0];

			$re = `cat /tmp/$ip.xml; rm /tmp/$ip.xml`;
			while($re =~m/<port protocol="tcp" portid="([0-9]+)">/gi){
				$porta = $1;
				print "$ip:$porta\n";
				$sql = "insert into sites.portscan(ip, porta) values('$ip', $porta)";
				print "$sql\n";
				$dbh->do($sql);
	}
$dbh->disconnect;
