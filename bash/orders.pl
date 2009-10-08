#!/usr/bin/perl

$no = 0; $mes = 0; $planet = 0;

$char = "[-!-\+\.-9\<-~]";
$object = $char."(".$char."| )*";
$shipprefix = "(TR\\d+|PB|CT|ES|FF|DD|CL|CS|CA|CC|BC|BS|DN|SD|BM|BW|BR)";
$gizmo = "(AU|DR|FD|FJ|FM|FS|GT|GU\\d|GW|IU|JP|PD|RM|SG\\d|SU|TP)";
$tech = "(MI|MA|ML|GV|LS|BI)";

$species = "SP\\s+".$object;
$coords = "\\d{1,2}\\s+\\d{1,2}\\s+\\d{1,2}";
$pcoords = $coords."\s+\\d";
$sship = $shipprefix."S{0,1}\\s+".$object; # any ship, incl. sublight
$fship = $shipprefix."\\s+".$object; # only FTL ship
$base = "BAS\\s+".$object;
$planet = "PL\\s+".$object;
$any = "(".$base."|".$sship."|".$planet.")"; #planet, base or ship

$problems = 0;

while ($line = <STDIN>) 
{
    $no++;
    chomp $line;
    ($command, @comment) = split /;/, $line;
	
	if ($command =~ /^\s*$/) {
		next;
	}
	
	$command =~ tr/a-z/A-Z/;
	
	if ($command =~ /$\s*START ([-\w]+)/) {
		if ($section ne "")	
		{
		    print "Line ".$no." : START inside section\n";
		    $problems = 1;
		}
		$section = $1;
		next;
	}
	
	if ($command =~ /$\s*END/) {
		if ($section eq "")
		{
			print "Line ".$no." : END without START\n";
			$problems = 1;
		}
		$section = "";
		next;
	}
	
	if ($section eq "")
	{
		print "Line ".$no." : Non-empty line outside section\n";
		$problems = 1;
		next;
	}
	
	$command =~ s/^\s+//;
	
	if ($section eq "COMBAT")
	{
		if ($command =~ /^ATT\w*\s+($species)$/) { next;}
		if ($command =~ /^BAT\w*\s+($coords)$/) { next;}
		if ($command =~ /^ENG\w*\s+([013]|[24-7]\s+\d)\s*$/) { next;}	
		if ($command =~ /^HAV\w*\s+($coords)\s*$/) { next;}
		if ($command =~ /^HID\w*\s+($sship)$/) { next;}
		if ($command =~ /^HIJ\w*\s+($species)$/) { next;}
		if ($command =~ /^SUM/) { next;}
		if ($command =~ /^TAR\w*\s+[1-4]/) { next;}
		if ($command =~ /^WIT\w*\s+($coords)$/) { next;}
		
		print "Line ".$no." : Illegal, incorrect or unrecognized $section command (".$command.")\n";
		$problems = 1;
		next;
	}
	
	if ($section eq "PRE-DEPARTURE")
	{
		if ($command =~ /^ZZZ\s*$/) { $mes=0; next;}
	
		if ($mes == 1) {next;}
		
		if ($command =~ /^MES\w*\s+($species)$/) { $mes=1; next;}			
		
		if ($command =~ /^ALL\w*\s+($species)$/) { next;}
		if ($command =~ /^BAS\w*\s+(\d+\s+){0,1}(($planet)|($sship)),\s*($base)$/) { next;}
		if ($command =~ /^DEE\w*\s+($sship)$/) { next;}
		if ($command =~ /^DES\w*\s+($sship)$/) { next;}				
		if ($command =~ /^DIS\w*\s+($planet)$/) { next;}
		if ($command =~ /^ENE\w*\s+($species)$/) { next;}
		if ($command =~ /^INS\w*\s+\d+\s+[AI]U\s+($planet)$/) { next;}	
		if ($command =~ /^LAN\w*\s+($sship)(,\s*($planet)){0,1}$/) { next;}
		if ($command =~ /^NAM\w*\s+($coords)\s+($planet)$/) { next;}
		if ($command =~ /^NEU\w*\s+($species)$/) { next;}
		if ($command =~ /^ORB\w*\s+($sship)(,\s*($planet)){0,1}$/) { next;}
		
		if ($command =~ /^REP\w*\s+($sship)(,\s*\d+\s*){0,1}$/) { next;}
		if ($command =~ /^REP\w*\s+($coords)\s+\d+\s*$/) { next;}
		
		if ($command =~ /^SCA\w*\s+($sship)$/) { next;}				
		if ($command =~ /^SEN\w*\s+\d+\s+($species)$/) { next;}
		if ($command =~ /^TRA\w*\s+\d+\s+($gizmo)\s+($any),\s*($any)$/) { next;}
		if ($command =~ /^UNL\w*\s+($sship)$/) { next;}
				
		print "Line ".$no." : Illegal, incorrect or unrecognized $section command (".$command.")\n";
		$problems = 1;
		next;
	}
	
	if ($section eq "JUMPS")
	{
		if ($command =~ /^JUM\w*\s+($fship),\s*(($coords)|($pcoords)|($planet))\s*$/) { next;}				
		if ($command =~ /^MOV\w*\s+(($fship)|($base)),\s*(($coords)|($pcoords)|($planet))\s*$/) { next;}
		if ($command =~ /^PJU\w*\s+($sship),\s*(($coords)|($pcoords)|($planet),)\s*($base)$/) { next;}				
		if ($command =~ /^VIS\w*\s+($coords)\s*$/) { next;}		
		if ($command =~ /^WOR\w*(($sship)|($base))(,\s*($planet))$/) { next;}
		
		print "Line ".$no." : Illegal, incorrect or unrecognized $section command (".$command.")\n";
		$problems = 1;
		next;
	}
	
	if ($section eq "PRODUCTION")
	{
		if ($command =~ /^PRO\w*\s+PL\s+\w[-\w\s]*$/) { $planet = 1; next;}
		
		if ($planet == 0) 
		{
			print "Line ".$no." : Production order before planet set\n";
			$problems = 1;
			next;
		}
		
		if ($command =~ /^ALL\w*\s+($species)$/) { next;}
		if ($command =~ /^AMB\w*\s+\d+\s*$/) { next;}
		
		if ($command =~ /^BUI\w*\s+(($sship)|($base))(,\s*\d+\s*){0,1}$/) { next;}
		if ($command =~ /^BUI\w*\s+\d+\s+($gizmo)(\s+($any)){0,1}\s*$/) { next;}
		
		if ($command =~ /^CON\w*\s+(($sship)|($base))(,\s*\d+\s*){0,1}$/) { next;}

		if ($command =~ /^DEV\s+(\d+\s+){0,1}(($planet)(,\s+($sship)){0,1}){0,1}$/) { next;}
				
		if ($command =~ /^ENE\w*\s+($species)$/) { next;}
		if ($command =~ /^EST\w*\s+($species)$/) { next;}
		if ($command =~ /^HID\w*\s*$/) { next;}
		
		if ($command =~ /^IBU\w*\s+($species)\s+(($sship)|($base))(,\s*\d+\s*){0,1}$/) { next;}
		if ($command =~ /^IBU\w*\s+($species)\s+\d+\s+($gizmo)(\s+($any)){0,1}\s*$/) { next;}
		
		if ($command =~ /^ICO\w*\s+($species)\s+(($sship)|($base))(,\s*\d+\s*){0,1}$/) { next;}
		
		if ($command =~ /^INT\w*\s+\d+\s*$/) { next;}
		if ($command =~ /^NEU\w*\s+($species)$/) { next;}
		if ($command =~ /^REC\w*\s+(($sship)|($base)|((\d+\s+){0,1}($gizmo)\s*))$/) { next;}
		if ($command =~ /^RES\w*\s+\d+\s+($tech)\s*$/) { next;}
		if ($command =~ /^SHI\w*\s*$/) { next;}
		if ($command =~ /^UPG\w*\s+(($sship)|($base))(,\s*\d+\s*){0,1}$/) { next;}

		print "Line ".$no." : Illegal, incorrect or unrecognized $section command (".$command.")\n";
		$problems = 1;
		next;
	}
	
	if ($section eq "POST-ARRIVAL")
	{
		if ($command =~ /^ZZZ\s*$/) { $mes = 0; next;}
	
		if ($mes == 1) {next;}
		
		if ($command =~ /^MES\w*\s+($species)$/) { $mes=1; next;}			
		
		if ($command =~ /^ALL\w*\s+($species)$/) { next;}
		if ($command =~ /^AUT\w*\s*$/) { next;}
		if ($command =~ /^DEE\w*\s+($sship)$/) { next;}
		if ($command =~ /^DES\w*\s+($sship)$/) { next;}				
		if ($command =~ /^ENE\w*\s+($species)$/) { next;}
		if ($command =~ /^LAN\w*\s+($sship)(,\s*($planet)){0,1}$/) { next;}
		if ($command =~ /^NAM\w*\s+($coords)\s+($planet)$/) { next;}
		if ($command =~ /^NEU\w*\s+($species)$/) { next;}
		if ($command =~ /^ORB\w*\s+($sship)(,\s*($planet)){0,1}$/) { next;}
		
		if ($command =~ /^REP\w*\s+($sship)(,\s*\d+\s*){0,1}$/) { next;}
		if ($command =~ /^REP\w*\s+($coords)\s+\d+\s*$/) { next;}
		
		if ($command =~ /^SCA\w*\s+($sship)$/) { next;}				
		if ($command =~ /^SEN\w*\s+\d+\s+($species)$/) { next;}
		if ($command =~ /^TEA\w*\s+($tech)\s+(\d+\s+){0,1}($species)$/) { next;}
		if ($command =~ /^TEL\w*\s+($base)$/) { next;}
		if ($command =~ /^TER\w*\s+(\d+\s+){0,1}($planet)$/) { next;}
		if ($command =~ /^TRA\w*\s+\d+\s+($gizmo)\s+($any),\s*($any)$/) { next;}
		
		print "Line ".$no." : Illegal, incorrect or unrecognized $section command (".$command.")\n";
		$problems = 1;
		next;
	}
	
	if ($section eq "STRIKE")
	{
	
		if ($command =~ /^ATT\w*\s+($species)$/) { next;}
		if ($command =~ /^BAT\w*\s+($coords)$/) { next;}
		if ($command =~ /^ENG\w*\s+([013]|[24]\s+\d)\s*$/) { next;}	
		if ($command =~ /^HAV\w*\s+($coords)\s*$/) { next;}
		if ($command =~ /^HID\w*\s+($sship)$/) { next;}
		if ($command =~ /^HIJ\w*\s+($species)$/) { next;}
		if ($command =~ /^SUM/) { next;}
		if ($command =~ /^TAR\w*\s+[1-4]/) { next;}
		if ($command =~ /^WIT\w*\s+($coords)$/) { next;}
							
		print "Line ".$no." : Illegal, incorrect or unrecognized $section command (".$command.")\n";
		$problems = 1;
		next;
	}
}

$problems || print "Orders parsed successfully - No errors found.\n";