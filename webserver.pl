#!/usr/bin/perl
use DBI;
use Socket;

use HTTP::Headers;
use HTTP::Request;
use LWP::UserAgent;






my $dbh = DBI->connect('DBI:mysql:;host=localhost','user','', {'PrintError'=>0}) or die("");
$x=0;
while(1){
	print "[+] Buscando sites para FingerPrint do Web Server\n";
	my $query = "select ip, id from `sites`.`ips` where webserver = 0 order by id asc limit 2000";
	my $query_handle = $dbh->prepare($query);
    	$query_handle->execute();
 	while ( @row = $query_handle->fetchrow_array ) {
		$x=1;
    	$ip = $row[0];
    	$id = $row[1];
		if(defined($ip)){
			my $response = HEAD("http://".$ip."/");
			my $s = $response->server;
			
			$s =~s/'/\\'/g if(defined($s));
			$s = "Nao identificado" if(!defined($s));
			$s = "Nao identificado" if($s eq "");
			$query = "UPDATE `sites`.`ips` SET webserver = 1 WHERE id = $id";
			$dbh->do($query);
			$sql = "insert into sites.webserver(ip_id, webserver) values('$id', '$s')";
			$dbh->do($sql);
			print "[+][$id] $ip : $s\n";
		}
    	else{
		exit;
		sleep(30);
		}
  	}
	if($x==0){
		print "[+] Aguardando novos dominios para fazer FingerPrint\n";
		exit;
	}
	$x=0;

}








sub HEAD(){
	my $url1 = shift;
#	print "HEAD: $url1\n";
	my $headers = HTTP::Headers->new();
	my $referer = "";
	my $useragent = $referer;
	$headers->remove_header('Connection');
	$headers->header('Accept' 		=> "*",
			'Accept-Language' 	=> "en-US,en",
			 'Accept-Encoding' 	=> "deflate",
			 'Connection' 		=> "Keep-alive",
			 'Keep-Alive'		=> 30);
	$headers->referer($referer);
	my $req=HTTP::Request->new('HEAD', $url1, $headers);
	my $ua=LWP::UserAgent->new(agent => $useragent, ssl_opts => { verify_hostname => 0} );
	$ua->timeout(3);
	$ua->max_size(1024*1024);
	$ua->protocols_allowed( [ 'http', 'https'] );

	my $response=$ua->request($req);

	return $response;

}
