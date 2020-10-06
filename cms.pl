#!/usr/bin/perl

use DBI;
use HTTP::Headers;
use HTTP::Request;
use LWP::UserAgent;
alarm(240);

my $site_id = $ARGV[0];

my $site = "https://". $ARGV[1] . "/";
our $urlsite = $site;
my $res = GET($site);
checa_cms($site_id, $res);

my @links = execute($site, $res);
my @links2 = ();

@links2 = &parser($res);
foreach my $link (@links){
	if($link =~/^https?/){
		push(@links2, $link);
	}
	else{
		push(@links2, 'https://'.$link.'/'); 
	}

}



my $dominio = &host($site);
my $protocolo = "";
my $diretorio = &diretorio_atual($site);

$protocolo = "http://" if($site =~/^http:\/\//i);
$protocolo = "https://" if($site =~/^https:\/\//i);

@links2 = &classifica_urls($protocolo, $dominio, $diretorio, @links2);
@links2 = &adiciona_diretorios(@links2);
@links2 = &verifica_ignorados(@links2);



foreach $link (@links2){
	
	insere_link($site_id, $link);
}


sub checa_cms(){
	my $site_id = shift;
	my $conteudo = shift;

	if($conteudo =~/wp\-content\//gi && $conteudo =~ /wp\-includes\//){
		insere($site_id, 'Wordpress');
		
	}

	elsif($conteudo =~/content="Joomla/gi && $conteudo =~ /\/media\/system\/js\/core\.js/) {
		insere($site_id, 'Joomla');

	}

	elsif($conteudo =~/content="Drupal/gi){
		insere($site_id, 'Drupal');
	}

	elsif($conteudo =~/Powered By Magento/gi){
		insere($site_id, 'Magento');
	}

	elsif($conteudo =~/\/bitrix\//gi){
		insere($site_id, 'Bitrix');
	}

	elsif($conteudo =~/Content="TYPO3/gi && $conteudo =~/typo3conf/){
		insere($site_id, 'TYPO3');
	}

	elsif($conteudo =~/content="Moodle/gi){
		insere($site_id, 'Moodle');
	}

	elsif($conteudo =~/powered by Weebly/gi){
		insere($site_id, 'Weebly');
	}

	elsif($conteudo =~/content="DataLife Engine/gi){
		insere($site_id, 'DataLife Engine');
	}

	elsif($conteudo =~/content="Sitefinity/gi){
		insere($site_id, 'Progress Sitefinity');
	}

	elsif($conteudo =~/dnn_ctr/gi){
		insere($site_id, 'DotNetNuke');
	}

	elsif($conteudo =~/bigcommerce\.com/gi){
		insere($site_id, 'Bigcommerce');
	}

	elsif($conteudo =~/Powered by ExpressionEngine/gi){
		insere($site_id, 'ExpressionEngine');
	}

	elsif($conteudo =~/jimcdn\.com/gi && $conteudo =~/jimdo_main_css/gi && $conteudo =~/jimdo_layout_css/gi){
		insere($site_id, 'Jimdo');
	}

	elsif($conteudo =~/content="vBulletin/gi){
		insere($site_id, 'vBulletin');
	}

	elsif($conteudo =~/Powered by Contao/gi){
		insere($site_id, 'Contao');
	}

	elsif($conteudo =~/phpbb_alert/gi && $conteudo =~/phpbb_confirm/gi){
		insere($site_id, 'phpBB');
	}

	elsif($conteudo =~/Powered by <span class="ast\-footer\-site\-title">shopware/gi){
		insere($site_id, 'Shopware');
	}

	elsif($conteudo =~/ontent="concrete5/gi){
		insere($site_id, 'Concrete5');
	}

	elsif($conteudo =~/osCommerce/gi){
		insere($site_id, 'osCommerce');
	}
	else{

		insere($site_id, 'Desconhecido');
	}
}



sub insere(){
	my $site_id = shift;
	my $cms = shift;
	my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>0}) or die("");
	my $sql = "insert into sites.cms(site_id, cms) values($site_id, '$cms')";
	#print "$site_id $cms\n";
	$dbh->do($sql);
	$dbh->disconnect;
}

sub insere_link(){
	my $site_id = shift;
	my $link = shift;
	my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>0}) or die("");
	my $sql = "insert into sites.link(site_id, link) values($site_id, '$link')";
	$dbh->do($sql);
	$dbh->disconnect;
}



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
	return '';	
	}

}

sub execute {
    my $url = shift;
    my $content = shift;

    my $url_uri = &host($url);
    $url = &get_url($url);

	my %ver = ();
	my @ret = ();
    my @ERs = (	"href=\"https?:\/\/(.+)\/\"", 
		"href='https?:\/\/(.+)\/'"
    );
			
	foreach my $er (@ERs){
		while ($content =~  m/$er/gi){
			my $link = $1;
			next if($link =~/[\s"']/);
			if($url ne $link){
	            if($link !~ /$url_uri/){
					if(!$ver{$link}){
							push(@ret,$link) if($link);
							$ver{$link} = 1;
					}
 			    }
			}
		}
	}
	return @ret;

}


sub host(){
	my $h = shift;
	my $url1 = URI->new( $h || return -1 );
	return $url1->host();
}

sub get_url(){
	my $url = shift;
	if($url =~/http:\/\//){
		$url =~s/http:\/\///g;
		$url = substr($url, 0, index($url, '/')) if($url =~/\//);
		return "http://" . $url;
	}
	if($url =~/https:\/\//){
		$url =~s/https:\/\///g;
		$url =  substr($url, 0, index($url, '/')) if($url =~/\//);
		return "https://" . $url;
	}
}


sub parser(){
	my $content = shift;	
	my @ERs = (	'href\s*=\s*"(.+?)"',
			'href\s*=\s*\'(.+?)\''
			);
	my @result = ();
	
	foreach my $er (@ERs){
		while($content =~ m/$er/gi){
			push(@result, $1);
		}
	} 

	return @result;
}


sub classifica_urls(){
	my ($protocolo, $dominio, $diretorio, @uurls) = @_;
	my @ret = ();
	$diretorio =~ s/\/\//\//g;
	$protocolo = 'http://' if($protocolo =~/^http:\// && $protocolo !~/http:\/\//);
	$protocolo = 'https://' if($protocolo =~/^https:\// && $protocolo !~/https:\/\//);
	
	foreach my $url (@uurls){
		next if($url =~/^htp:\//);
		next if($url =~/file:\/\//gi);
		next if($url =~/ \+ /gi);
		next if($url =~/connect\.facebook\.net/i);
		next if($url =~/ajax\.googleapis\.com/i);
		next if($url =~/www\.facebook\.com/i);
		next if($url =~/^ [A-Za-z]+=/i);
		next if($url =~/mms:\/\//gi);
		
		
		
		$url =~s/^ // if($url =~/^ https?:/);
		
		if($url =~/^http:\// && $url !~/http:\/\//){
			$url =~ s/^http:\//http:\/\//;
		}

		if($url =~/^https:\// && $url !~/https:\/\//){
			$url =~ s/^https:\//https:\/\//;
		}

		$url = &trata_url($url);
		next if($url =~ m/javascript:|mailto:/gi);
		# retira os n ../ e volta n diretorios
		my $temp_dir = $diretorio;
		while($url =~/^\.\.\//){
			$url = substr($url, 3, length($url));
			$temp_dir =~s/\/$//;
			$temp_dir = substr($temp_dir, 0, rindex($temp_dir, '/')+1);
		}
		
		while($url =~/\.\.\//){
			$url = &volta_dir($url);
		}
		$url =~s/^\.\///g;
		
		#limpezas:
		my $flag = 0;
		$flag = 1 if($url =~/\|#\|/);
		#print "$url\n" if($flag);
		my $tmp = substr($url, index($url, '|#|'), length($url)) if($url =~/\|#\|/);
		#print "tmp $tmp\n" if($flag);
		$url = substr($url, 0, index($url, '|#|')) if($url =~/\|#\|/);
		#print "$url\n" if($flag);
		$url =~s/'//g;
		$url =~s/"//g;
		if($url =~ /^\.\//){
			$url = substr($url, 2, length($url));
		}
		#se come\E7a com https?:\/\/ e contem o dominio entao adiciona ao retorno
		$url .= $tmp if($flag == 1);
		#print "$url\n" if($flag);
		
		push(@ret, $url) if($url =~ m/^https?:\/\/\Q$dominio\E/i && $url =~/^$urlsite/);
		
		#se come\E7a com /, adiciona https?:// + dominio + url ao retorno
		push(@ret, $protocolo . $dominio . $url) if($url =~/^\//);
		
		#se n\E3o come\E7a com https:// e n\E3o come\E7a com /: add ao ret : https:// $dominio $diretorio $url
		push(@ret, $protocolo . $dominio . $temp_dir . $url) if($url !~/^https?:\/\//i && $url !~ /^\//);
		
	}
	
	return @ret;
}

sub verifica_ignorados(){
	my @uurls = @_;
	my @ret = ();
	my $exten = ".wmv.exe.pdf.xls.csv.mdb.rpm.deb.doc.odt.pptx.docx.db.xps.cdr.jpg.jpeg.png.gif.bmp.css.tgz.gz.bz2.mp4.zip.rar.tar.asf.avi.bin.dll.js.fla.mp3.mpg.mov.ogg.ppt.rtf.scr.wav.msi.swf.flv.ogv.ico";
	foreach my $url (@uurls){
		$url = &trata_url($url);
		my $fil = get_file($url);
		my $ext = &get_extension($fil);
		if($exten !~/$ext/i){
			if (!$checado{$url}) {
				$checado{$url} = 1;
				my $temp = $url;
				$url = substr($url, 0, index($url, '|#|')) if($url =~/\|#\|/);
				$url = $temp;
					push(@ret, $url);
				
			}
		}
		else{
		}
	}
	return(@ret);
	
}

sub adiciona_diretorios(){
	my @uurls = @_;
	my @ret = ();
	my %controle;
	
	foreach my $url (@uurls){
		$url = &trata_url($url);
		$controle{$url}=1 if($url =~/^$urlsite/);
		while(length($url)>13){
			$url = substr($url, 0, rindex($url, '/'));
			$controle{$url."/"} = 1 if(length($url)>13 && $url =~ /^$urlsite/i);
		}
	}
	foreach my $key (keys %controle){
		push(@ret, $key) if($key =~/^$urlsite/i);
	}
	return(@ret);
}


sub diretorio_atual(){
	my $url = shift;
	
	$url =~s/https?:\/\///;
	my $dir = substr($url, index($url, '/'), length($url));
	$dir = substr($dir, 0, rindex($dir, '/')+1);
	$dir = '/' if($dir !~/^\//);
	return $dir;
	
}

sub trata_url(){
	my $url = shift;

	$url =~s/&quot;/%22/gi;
	$url =~s/&amp;/&/gi;
	$url =~s/&lt;/%3C/gi;
	$url =~s/&gt;/%3E/gi;
	$url =~s/&Aacute;/%C3%81/gi;
	$url =~s/&nbsp;/%20/gi;
	$url =~s/&Acirc;/%C3%82/gi;
	$url =~s/&Agrave;/%C3%80/gi;
	$url =~s/&Atilde;/%C3%83/gi;
	$url =~s/&aacute;/%C3%A1/gi;
	$url =~s/&acirc;/%C3%A2/gi;
	$url =~s/&agrave;/%C3%A0/gi;
	$url =~s/&atilde;/%C3%A3/gi;
	$url =~s/&Eacute;/%C3%89/gi;
	$url =~s/&Ecirc;/%C3%8A/gi;
	$url =~s/&Egrave;/%C3%88/gi;
	$url =~s/&eacute;/%C3%A9/gi;
	$url =~s/&ecirc;/%C3%AA/gi;
	$url =~s/&egrave;/%C3%A8/gi;
	$url =~s/&Iacute;/%C3%8D/gi;
	$url =~s/&Icirc;/%C3%8E/gi;
	$url =~s/&Igrave;/%C3%8C/gi;
	$url =~s/&icirc;/%C3%AE/gi;
	$url =~s/&igrave;/%C3%AC/gi;
	$url =~s/&Oacute;/%C3%93/gi;
	$url =~s/&Ocirc;/%C3%94/gi;
	$url =~s/&Ograve;/%C3%92/gi;
	$url =~s/&Otilde;/%C3%95/gi;
	$url =~s/&oacute;/%C3%B3/gi;
	$url =~s/&ocirc;/%C3%B4/gi;
	$url =~s/&ograve;/%C3%B2/gi;
	$url =~s/&otilde;/%C3%B5/gi;
	$url =~s/&Uacute;/%C3%9A/gi;
	$url =~s/&Ucirc;/%C3%9B/gi;
	$url =~s/&Ugrave;/%C3%99/gi;
	$url =~s/&uacute;/%C3%BA/gi;
	$url =~s/&ucirc;/%C3%BB/gi;
	$url =~s/&ugrave;/%C3%B9/gi;
	$url =~s/ /%20/gi;
	$url =~s/\+/%2B/gi;
	$url =~s/&Ccedil;/%C3%87/gi;
	$url =~s/&ccedil;/%C3%A7/gi;
	return $url;
}

sub get_file(){
	my $url1 = shift;
	substr($url1,0,7) = "" if($url1 =~/http:\/\//);
	substr($url1,0,8) = "" if($url1 =~/https:\/\//);
	substr($url1, index($url1, '?'), length($url1)) = "" if($url1 =~/\?/);
	substr($url1, index($url1, '|#|'), length($url1)) = "" if($url1 =~/\|#\|/);
	if($url1 =~ /\//){
		$url1 = substr($url1, index($url1, '/'), length($url1)) if(length($url1) != index($url1, '/'));
		if($url1 =~ /\?/){
			$url1 = substr($url1, 0, index($url1, '?'));
		}
		return $url1;
	}
	elsif($url1=~/\?/){
		$url1 = substr($url1, 0, index($url1, '?'));
		return $url1;
	}
	else {
		return $url1;
	}
}


	sub get_extension(){
		my  $file = shift;
		if($file =~/\./){
			my $ext = substr($file, rindex($file, '.'), length($file));
			$ext =~ s/ //g;
			if($ext !~/\(|\)|\-|\//){
				return $ext;
			}
			else {
				return 0;
			}
		}
		else{
			return 0;
		}
	}



sub checa_head(){
	my @uurls = @_;
	my @ret = ();
	foreach my $url (@uurls){
		next if($url !~/\?/);
		$url = &trata_url($url);
		if (!$checado2{$url}) {
			$checado2{$url} = 1;
			my $temp = $url;
			$url = substr($url, 0, index($url, '|#|')) if($url =~/\|#\|/);
			my $response = HEAD($url);
			$url = $temp;
			$requests++;
			if($response->code !~ /401|403|404/ && $response->code){
				push(@ret, $url) if($url =~ /^$urlsite/i);
			}
			else{
#				open(a, ">>error.txt");
#				print a __LINE__ . " code: " .$response->code . " $url \n";
#				close(a);
			}
		}
	}
	return(@ret);
	
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
	$ua->timeout(15);
	$ua->max_size(1024*1024);
	$ua->protocols_allowed( [ 'http', 'https'] );
	#$ua->cookie_jar($cookie_jar);
	
	my $response=$ua->request($req);

	return $response;

}

sub volta_dir(){
	my $url = shift;
	my $pos = index($url, '../');
	#print "pos: $pos\n";
	my $str1 = substr($url, 0, $pos-1);
	$str1 = substr($url, 0, rindex($str1, '/'));
	my $str2 = substr($url, $pos+2, length($url));
	#print "1 $str1\n2 $str2\n";
	return $str1.$str2;
}
