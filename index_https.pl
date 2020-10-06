#!/usr/bin/perl
use DBI;
use HTTP::Headers;
use HTTP::Request;
use LWP::UserAgent;

$id = $ARGV[0];
$site = $ARGV[1];

my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>1}) or die("");

print "index ID: $id \tSite: $site\n";
$s = &GET('https://'. $site.'/');
$s =~s/'//g if(defined($s));
$query = "UPDATE `sites`.`site` SET pagina = '$s' WHERE id = $id";
$dbh->do($query);



sub GET(){
    my $url1 =shift;
	return 0 if(!$url1);
	return 0 if($url1 !~/^https?:\/\//);
	my $headers = HTTP::Headers->new();
	$headers->remove_header('Connection');
	$headers->header('Accept' 		=> "text/html, application/xhtml+xml, application/xml",
			'Accept-Language' 	=> "en-US,en",
			 'Accept-Encoding' 	=> "gzip, deflate",
			 'Connection' 		=> "Keep-alive",
			 'Keep-Alive'		=> 30);

	my $req = HTTP::Request->new('GET', $url1, $headers);
    my $ua	= LWP::UserAgent->new(agent => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7", ssl_opts => { verify_hostname => 0} );

    $ua->timeout(15);
    $ua->max_size(1024*1024);
	$ua->protocols_allowed( [ 'http', 'https']);
    my $response=$ua->request($req);
	if($response->is_success){
	        return $response->decoded_content;
	}
	else{
		return '404';
	}

}
