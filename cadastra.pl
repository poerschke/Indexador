#!/usr/bin/perl
use DBI;
use strict;

open(a, "<sites.txt");
my @site = <a>;
close(a);

foreach my $s (@site){
	chomp $s;
	$s = lc($s);
		my $dbh = DBI->connect('DBI:mysql:;host=localhost','root','', {'PrintError'=>1}) or die("");
		my $query = "INSERT INTO `sites`.`site` (url)  VALUES ('$s');";
		my $query_handle = $dbh->prepare($query);
    	$query_handle->execute();
		print "Site: $s\n";	
}
