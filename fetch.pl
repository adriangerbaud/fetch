#!/usr/bin/perl

#Declare useful variables

$UNIXenddate = `date +%s`;
chomp $UNIXenddate;

$date = `date +%b-%d-%Y`;
chomp $date;

$datetime = `date "+%H:%M:%S %b-%d-%Y"`;
chomp $datetime;

$wd = `pwd`;
chomp $wd;
$datapath = "$wd/data";

$year = `date +%Y`;
chomp $year;
$startdate= `date -d "$year-01-01 00:00:00" "+%s"`;
chomp $startdate;

#make data folder if it does not exist

unless(-e $datapath)
{
`mkdir data`;
}


# Populate sites hash

%sites = ( Lira => ["lmnd33", "$datapath/Lira"],
	   Pabo => ["lmnd27", "$datapath/Pabo"],
	   Lacor => ["lmnd34", "$datapath/Lacor"],
	 );

#Download the data.
foreach $sitecode (keys %sites)
{
	`curl "http://$sites{$sitecode}[0].egaug.es/cgi-bin/egauge-show\?d\&s=0\&c\&t=$startdate\&f=$UNIXenddate\&Z=:EAT" -o "$sites{$sitecode}[1]-$date.csv" -fs`;
	$p= $? >> 8;

#If new data is availabe, erase the old data
	if($p == 0 )
	{	

	$remove = `ls $datapath | grep '$sitecode' | grep -v "$date"`;
	`rm -f $datapath/$remove`; #remove it if it is there
#	print "$remove\n"
	}
}

#make a log file that will show when the script has run. (Debugging purposes)

`touch "$datapath/time.log"`;

open(FH, ">>", "$datapath/time.log") or die "Cannot open file";
select FH;
print "Script ran at $datetime\n";
close FH;

# Send file to windows server (192.168.3.16/Office)  mounted on ubuntu server (192.168.3.20)
`mount -a`;
`rm /mnt/Office/eGaugeData/*`;
`cp $datapath/* /mnt/Office/eGaugeData`;

