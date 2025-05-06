#!/usr/bin/perl
#
# DocBrown/Wizard Sorter v1.3
# Written by Derek Pascarella (ateam)
#
# SD card sorter for the FM Towns/Marty ODEs DocBrown and Wizard.

# Include necessary modules.
use strict;
use File::Basename;
use File::Find::Rule;

# Set version number.
my $version = "1.3";

# Initialize input variables.
my $sd_path_source = $ARGV[0];

# Declare/initialize variables.
my %game_list;
my $game_count_found = 0;
my $game_count = 1;
my $invalid_count = 0;

# Set header used in CLI messages.
my $cli_header = "\nDocBrown/Wizard Sorter v" . $version . "\nWritten by Derek Pascarella (ateam)\n\n";

# No valid SD card path specified.
if(!-d $sd_path_source || !-e $sd_path_source || $sd_path_source eq "")
{
	print $cli_header;
	print STDERR "Error: No SD card path specified.\n\n";
	print "Example Usage: towns_sorter H:\\\n\n";
	print "Press Enter to exit.\n";
	<STDIN>;

	exit;
}
# SD card path is unreadable.
elsif(!-R $sd_path_source)
{
	print $cli_header;
	print STDERR "Error: Specified SD card path is unreadable.\n\n";
	print "Example Usage: towns_sorter H:\\\n\n";
	print "Press Enter to exit.\n";
	<STDIN>;

	exit;
}

# Status message.
print $cli_header;
print "Processing SD card (" . $sd_path_source . ")...\n\n";

# Create temporary folder for purposes of sorting FAT filesystem.
mkdir($sd_path_source . "/towns_sorter_temp/");

# Open SD card path for reading.
opendir(my $sd_path_source_handler, $sd_path_source);

# Iterate through contents of SD card in alphanumeric order.
foreach my $sd_subfolder (sort { 'numeric'; $a <=> $b }  readdir($sd_path_source_handler))
{
	# Skip folders starting with a period.
	next if($sd_subfolder =~ /^\./);
	
	# Skip all non-folders (e.g., "DocBrown.ini", "Wizard.ini", etc).
	next if(!-d $sd_path_source . "/" . $sd_subfolder);
	
	# Skip folder "01" containing Almanac/Spellbook.
	next if($sd_subfolder eq "01");

	# Ignore Windows system folder.
	next if($sd_subfolder eq "System Volume Information");

	# Store list of all files in subfolder.
	my $sd_subfolder_rule = File::Find::Rule->new;
	$sd_subfolder_rule->file;
	$sd_subfolder_rule->maxdepth(1);
	my @sd_subfolder_files = $sd_subfolder_rule->in($sd_path_source . "/" . $sd_subfolder);

	# Set game-found flag to zero.
	my $game_found = 0;

	# Consider folder as storing a game if "title.txt" is found.
	if(-e $sd_path_source . "/" . $sd_subfolder . "/Title.txt")
	{
		$game_found = 1;
	}
	# Otherwise, iterate through each file to locate valid disc image.
	else
	{
		foreach(@sd_subfolder_files)
		{
			my $suffix = (fileparse($_, qr"\..[^.]*$"))[2];

			if(lc($suffix) eq ".cdi" || lc($suffix) eq ".ccd" || lc($suffix) eq ".img" ||
			   lc($suffix) eq ".bin" || lc($suffix) eq ".iso" || lc($suffix) eq ".mdf")
			{
				$game_found = 1;
			}
		}
	}

	# To prevent folder name conflicts, rename invalid folder for user to process manually.
	if(!$game_found && $sd_subfolder ne "towns_sorter_temp")
	{
		$invalid_count ++;

		rename($sd_path_source . "/" . $sd_subfolder, $sd_path_source . "/INVALID_" . $invalid_count);
	}

	# If folder contains no game disc image, skip it.
	next if(!$game_found);

	# Declare game name variable.
	my $game_name;

	# Store game name from "title.txt".
	if(-e $sd_path_source . "/" . $sd_subfolder . "/" . "Title.txt")
	{
		$game_name = read_file($sd_path_source . "/" . $sd_subfolder . "/" . "Title.txt");
		$game_name =~ s/^\s+|\s+$//g;
	}
	# Store folder name as game name.
	else
	{
		$game_name = $sd_subfolder;
		$game_name =~ s/^\s+|\s+$//g;
		$game_name =~ s/\s+/ /g;

		# Write "title.txt" file.
		write_file($sd_path_source . "/" . $sd_subfolder . "/" . "Title.txt", $game_name);
	}

	# Add game to hash.
	$game_list{$game_name} = $sd_subfolder;

	# Increase detected game count by one.
	$game_count_found ++;

	# For purposes of FAT sorting, create temporary folder for game.
	mkdir($sd_path_source . "/towns_sorter_temp/" . $sd_subfolder);
	
	# Open game folder for reading.
	opendir(my $game_folder_handler, $sd_path_source . "/" . $sd_subfolder);

	# Iterate through contents of game folder.
	foreach my $game_folder_file (readdir($game_folder_handler))
	{
		# Move each file into temporary folder.
		rename($sd_path_source . "/" . $sd_subfolder . "/" . $game_folder_file,
		       $sd_path_source . "/towns_sorter_temp/" . $sd_subfolder . "/" . $game_folder_file);
	}

	# Close game folder.
	closedir($game_folder_handler);

	# Remove original game folder.
	rmdir($sd_path_source . "/" . $sd_subfolder);
}

# Close SD card path.
closedir($sd_path_source_handler);

# No games found on target SD card.
if(!$game_count_found)
{
	print "No disc images detected on SD card.\n\n";
	print "Press Enter to exit.\n";
	<STDIN>;

	exit;
}

# Prompt before continuing.
print $game_count_found . " disc image(s) found and pre-processed on SD card.\n\n";
print "These disc images have been moved to a temporary folder on the SD card for\n";
print "purposes of FAT sorting.\n\n";
print "In five seconds, disc images will be auomatically organized using numbered\n";
print "folders in alphanumeric order.\n\n";

# Sleep for five seconds before proceeding.
sleep(5);

# Iterate through each key in game list hash, processing each folder move/rename.
foreach my $folder_name (sort {lc $a cmp lc $b} keys %game_list)
{
	# Increase game count by one.
	$game_count ++;

	# Generate game folder's new name.
	my $sd_subfolder_new = $game_count;
	
	if($game_count < 10)
	{
		$sd_subfolder_new = "0" . $sd_subfolder_new;
	}
	
	# Status message.
	print "  -> Folder " . $sd_subfolder_new . " ";

	if($game_list{$folder_name} eq $sd_subfolder_new)
	{
		print "(unchanged: ";
	}
	elsif($game_list{$folder_name} ne $folder_name && $game_list{$folder_name} =~ /^\d+$/)
	{
		print "(previously " . $game_list{$folder_name} . ": ";
	}
	else
	{
		print "(new: ";
	}

	print $folder_name . ")\n";

	# Create game folder based on new sorted name.
	mkdir($sd_path_source . "/" . $sd_subfolder_new);
	
	# Open temporary game folder for reading.
	opendir(my $game_folder_handler, $sd_path_source . "/towns_sorter_temp/" . $game_list{$folder_name});

	# Iterate through contents of temporary game folder.
	foreach my $game_folder_file (readdir($game_folder_handler))
	{
		# Move each file back from temporay game folder.
		rename($sd_path_source . "/towns_sorter_temp/" . $game_list{$folder_name} . "/" . $game_folder_file,
		       $sd_path_source . "/" . $sd_subfolder_new . "/" . $game_folder_file);
	}

	# Close game folder.
	closedir($game_folder_handler);

	# Remove temporary game folder.
	rmdir($sd_path_source . "/towns_sorter_temp/" . $game_list{$folder_name});
}

# Remove temporary folder.
rmdir($sd_path_source . "/towns_sorter_temp/");

# Status message.
print "\n" . $game_count_found . " disc images(s) fully processed!\n\n";

# If invalid game folders were found, list them along with a message.
if($invalid_count)
{
	print $invalid_count . " invalid folder(s) found. To avoid naming conflicts, they've been renamed to:\n";

	for(1 .. $invalid_count)
	{
		print "  -> INVALID_" . $_ . "\n";
	}

	print "\n";
}

# Prompt to run Almanac/Spellbook batch script until valid response given.
my $batch_response;

while($batch_response !~ /^[YN]$/i)
{
	print "Run Almanac/Spellbook batch script? (Y/N) ";
	chop($batch_response = <STDIN>);
}

# Execute Almanac/Spellbook's "RunMe.bat" script.
if(lc($batch_response) eq "y")
{
	# Almanac/Spellbook batch script found.
	if(-e $sd_path_source . "/01/RunMe.bat")
	{
		print "\n==========RunMe.bat==========\n";

		chdir($sd_path_source . "/01/");
		system("RunMe.bat");

		print "=============================\n";
	}
	# Batch script not found.
	else
	{
		#print "\nThe \"RunMe.bat\" script was not found in folder \"01\"!\n";
		print "\nThe \"RunMe.bat\" script was not found in folder 01!\n";
	}
}

# Status message.
print "\nSD card processing complete!\n\n";
print "An index of disc images can be found in the following location:\n";
print $sd_path_source;

if(substr($sd_path_source, -1) ne "\\")
{
	print "\\";
}

print "01\\data\\TITLES.TXT\n\n";
print "Press Enter to exit.\n";
<STDIN>;

# Subroutine to read a specified file.
#
# 1st parameter - File to read.
sub read_file
{
	my ($filename) = @_;

	open my $in, '<:encoding(UTF-8)', $filename or die "Could not open '$filename' for reading $!";
	local $/ = undef;
	my $all = <$in>;
	close $in;

	return $all;
}

# Subroutine to write content to a specified file.
#
# 1st parameter - File to write.
# 2nd parameter - Content to write.
sub write_file
{
	my ($filename, $contents) = @_;

	open my $out, '>', $filename;
	print $out $contents;
	close $out;
}