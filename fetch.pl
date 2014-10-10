#!/usr/bin/perl

use Data::Dumper;
use strict;
use warnings;

#Declare useful variables

my $fetchdir = "/home/ec2-user/fetch";

my $UNIXenddate = `date +%s`;
chomp $UNIXenddate;

my $date = `date +%b-%d-%Y`;
chomp $date;

my $datetime = `date "+%H:%M:%S %b-%d-%Y"`;
chomp $datetime;

my $datapath = "$fetchdir/data";

my $year = `date +%Y`;
chomp $year;

my $startdate= `date -d "$year-01-01 00:00:00" "+%s"`;
chomp $startdate;

#make data folder if it does not exist

#print "$datapath\n";

unless(-e $datapath)
{
`mkdir $datapath`;
}



# Populate sites hash
my %sites;

open my $fh, '<', "$fetchdir/sites.csv" or die "Cannot open sites.csv: $!";
while(my $line = <$fh>)
{
    my @array = split/,/, $line;
    chomp $array[1];
    
    # print "$destination\n";
    $sites{$array[0]} = [$array[1] , "$datapath/$array[0]"];
    
}

#print Dumper \%sites;

close $fh;

#Download the data.
foreach my $sitecode (keys %sites)
{
	`curl "http://$sites{$sitecode}[0].egaug.es/cgi-bin/egauge-show\?d\&s=0\&c\&t=$startdate\&f=$UNIXenddate\&Z=:EAT" -o "$sites{$sitecode}[1]-$date.csv" -fs`;
	my  $p= $? >> 8;


	#print "curl http://$sites{$sitecode}[0].egaug.es/cgi-bin/egauge-show?d&s=0&c&t=$startdate&f=$UNIXenddate&Z=:EAT -o $sites{$sitecode}[1]-$date.csv";
#If new data is availabe, erase the old data
	if( $p == 0 )
	{	

	my $remove = `ls $datapath | grep '$sitecode' | grep -v "$date"`;
	`rm -f $datapath/$remove`; #remove it if it is there
	}
}

#make a log file that will show when the script has run. (Debugging purposes)

`touch "$datapath/time.log"`;

open(FH, ">>", "$datapath/time.log") or die "Cannot open file";
select FH;
print "Script ran at $datetime\n";
close FH;
