#!/usr/bin/perl
#
# DocBrown/Wizard Sorter v1.0
# Written by Derek Pascarella (ateam)
#
# SD card sorter for the FM Towns/Marty ODEs DocBrown and Wizard.

# Include necessary modules.
use strict;
use File::Basename;
use File::Find::Rule;

# Define input variables.
my $sd_path_source = $ARGV[0];

# Define/initialize variables.
my %game_list;
my $game_count_found = 0;
my $game_count = 1;
my $invalid_count = 0;

# No valid SD card path specified.
if(!-d $sd_path_source || !-e $sd_path_source || $sd_path_source eq "")
{
	print "\nDocBrown/Wizard Sorter v1.0\n";
	print "Written by Derek Pascarella (ateam)\n\n";
	print "Error: No SD card path specified.\n\n";
	print "Example Usage: docbrown_sorter H:\\\n\n";
	print "Press Enter to exit.\n";
	<STDIN>;

	exit;
}
# SD card path is unreadable.
elsif(!-R $sd_path_source)
{
	print "\nDocBrown/Wizard Sorter v1.0\n";
	print "Written by Derek Pascarella (ateam)\n\n";
	print "Error: Specified SD card path is unreadable.\n\n";
	print "Example Usage: docbrown_sorter H:\\\n\n";
	print "Press Enter to exit.\n";
	<STDIN>;

	exit;
}

# Status message.
print "\nDocBrown/Wizard Sorter v1.0\n";
print "Written by Derek Pascarella (ateam)\n\n";

# Open SD card path for reading.
opendir(my $sd_path_source_handler, $sd_path_source);

# Iterate through contents of SD card in alphanumeric order.
foreach my $sd_subfolder (sort { 'numeric'; $a <=> $b }  readdir($sd_path_source_handler))
{
	# Skip folders starting with a period.
	next if($sd_subfolder =~ /^\./);
	
	# Skip all non-folders (e.g., files like "DocBrown.ini").
	next if(!-d $sd_path_source . "/" . $sd_subfolder);
	
	# Skip folder "01" containing GDMenu.
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
			(my $name, my $path, my $suffix) = fileparse($_, qr"\..[^.]*$");

			if(lc($suffix) eq ".cdi" || lc($suffix) eq ".ccd" || lc($suffix) eq ".img"
				|| lc($suffix) eq ".bin" || lc($suffix) eq ".iso" || lc($suffix) eq ".mdf")
			{
				$game_found = 1;
			}
		}
	}

	# To prevent folder name conflicts, rename invalid folder for user to process manually.
	if(!$game_found)
	{
		$invalid_count ++;

		rename($sd_path_source . "/" . $sd_subfolder, $sd_path_source . "/INVALID_" . $invalid_count);
	}

	# If folder contains no game disc image, skip it.
	next if(!$game_found);

	# Define game name variable.
	my $game_name;

	# Store game name from "title.txt".
	if(-e $sd_path_source . "/" . $sd_subfolder . "/" . "Title.txt")
	{
		$game_name = &read_file($sd_path_source . "/" . $sd_subfolder . "/" . "Title.txt");
		$game_name =~ s/^\s+|\s+$//g;
	}
	# Store folder name as game name.
	else
	{
		$game_name = $sd_subfolder;
		$game_name =~ s/[^A-Za-z0-9\s+\-\.\,\(\)\[\]]//g;
		$game_name =~ s/\s+/ /g;

		# Write "title.txt" file.
		&write_file($sd_path_source . "/" . $sd_subfolder . "/" . "Title.txt", $game_name);
	}

	# Add game to hash.
	$game_list{$game_name} = $sd_subfolder;

	# Increase detected game count by one.
	$game_count_found ++;

	# Temporarily append underscore to game folder name.
	rename($sd_path_source . "/" . $sd_subfolder, $sd_path_source . "/" . $sd_subfolder . "_");
}

# Close SD card path.
closedir($sd_path_source_handler);

# No games found on target SD card.
if(!$game_count_found)
{
	print "No games detected on SD card.\n\n";
	print "Press Enter to exit.\n";
	<STDIN>;

	exit;
}

# Prompt before continuing.
print $game_count_found . " game(s) found on SD card.\n\n";

# Iterate through each key in game list hash, processing each folder move/rename.
foreach my $folder_name (sort {lc $a cmp lc $b} keys %game_list)
{
	# Increase game count by one.
	$game_count ++;

	# Generate game folder's new name.
	my $sd_subfolder_new = $game_count;
	if($game_count < 10) { $sd_subfolder_new = "0" . $sd_subfolder_new;	}
	
	# Print status message.
	print "[" . $folder_name . "]\n";
	print "   -> Moved \"" . $game_list{$folder_name} . "\" -> \"" . $sd_subfolder_new . "\"\n\n";

	# Rename folder.
	rename($sd_path_source . "/" . $game_list{$folder_name} . "_", $sd_path_source . "/" . $sd_subfolder_new);
}

# Print status message.
print $game_count_found . " game(s) processed!\n\n";

# If invalid game folders were found, list them along with a message.
if($invalid_count)
{
	print $invalid_count . " invalid folder(s) found. To avoid naming conflicts, they've been renamed to:\n";

	for(1 .. $invalid_count)
	{
		print "   -> INVALID_" . $_ . "\n";
	}

	print "\n";
}

# Prompt to run Almanac/Spellbook batch script.
print "Run Almanac/Spellbook batch script? (Y/N) ";
chop(my $batch_response = <STDIN>);

# Execute Almanac/Spellbook's "RunMe.bat" script.
if(lc($batch_response) eq "y")
{
	# Almanac/Spellbook batch script found.
	if(-e $sd_path_source . "/01/")
	{
		print "\n==========RunMe.bat==========\n";

		chdir($sd_path_source . "/01/");
		system("RunMe.bat");

		print "=============================\n";
	}
	# Batch script not found.
	else
	{
		print "\nThe \"RunMe.bat\" script was not found in folder \"01\"!\n";
	}
}

# Final message.
print "\nPress Enter to exit.\n";
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