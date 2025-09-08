#!/usr/bin/perl
#
# DocBrown/Wizard Sorter v1.4
# Written by Derek Pascarella (ateam)
#
# SD card sorter for the FM Towns/Marty ODEs DocBrown and Wizard.

# Include necessary modules.
use strict;
use File::Basename;

# Set version number.
my $version = "1.4";

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

# Warning message requiring user to press Enter before continuing.
print "WARNING: Before proceeding, ensure that no files or folders on SD card (" . $sd_path_source . ")\n";
print "         are open in File Explorer or any other program. Failure to do so\n";
print "         will result in data corruption!\n\n";
print "Press Enter to continue...\n";

<STDIN>;

# If last automatically generated GameList.txt file exists, perform comparison with
# current version in root of SD card to identify title changes to be carried out.
if(-e $sd_path_source . "/01/GameList.txt" && !files_are_identical($sd_path_source . "/GameList.txt", $sd_path_source . "/01/GameList.txt"))
{
	# Status message and prompt.
	my $title_prompt;

	print "The \"GameList.txt\" file in the root of the SD card has been changed since\n";
	print "the last time it was processed. Update folder titles to reflect changes\n";
	print "made to the list text file? (Y/N) ";

	while($title_prompt ne "Y" && $title_prompt ne "N")
	{
		chop($title_prompt = uc(<STDIN>));
	}

	# Perform title update.
	if($title_prompt eq "Y")
	{
		# Find changed lines in GameList.txt.
		my $list_old = read_file($sd_path_source . "\\01\\GameList.txt");
		my $list_new = read_file($sd_path_source . "\\GameList.txt");

		my @lines_old = split(/\R/, $list_old);
		my @lines_new = split(/\R/, $list_new);

		my $max = @lines_old > @lines_new ? @lines_old : @lines_new;

		for(my $i = 0; $i < $max; $i ++)
		{
			my $old = $lines_old[$i] // "";
			my $new = $lines_new[$i] // "";

			next if($old eq $new);

			# Extract folder number and new title.
			my ($folder_number, $new_title) = $new =~ /^\s*(\d+)\s*-\s*(.+?)\s*$/;

			# Skip if not matched or if folder number is 01.
			next unless(defined $folder_number && defined $new_title);
			next if($folder_number eq "01");

			# Update title text file.
			write_file($sd_path_source . "\\" . $folder_number . "\\Title.txt", $new_title);
		}

		# Status message.
		print "\nTitle update complete!\n";
	}

	print "\n";
}

# Status message.
print "Processing SD card (" . $sd_path_source . ")...\n\n";

# Create temporary folder for purposes of sorting FAT filesystem.
mkdir($sd_path_source . "/towns_sorter_temp/");

# Store list of files in game folder.
my @sd_path_source_files = folder_list($sd_path_source, 1);

# Iterate through contents of SD card in alphanumeric order.
foreach my $sd_subfolder (@sd_path_source_files)
{
	# Skip folders starting with a period.
	next if($sd_subfolder =~ /^\./);
	
	# Skip all non-folders (e.g., "DocBrown.ini", "Wizard.ini", etc).
	next if(!-d $sd_path_source . "/" . $sd_subfolder);
	
	# Skip folder "01" containing Almanac/Spellbook.
	next if($sd_subfolder eq "01");

	# Ignore Windows system folder.
	next if($sd_subfolder eq "System Volume Information");

	# Ignore temporary folder.
	next if($sd_subfolder eq "towns_sorter_temp");

	# Store list of all files in subfolder.
	my @sd_subfolder_files = folder_list($sd_path_source . "/" . $sd_subfolder);

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
	if(!$game_found)
	{
		$invalid_count ++;

		rename_until_free($sd_path_source . "/" . $sd_subfolder,
						  $sd_path_source . "/INVALID_" . $invalid_count);
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
	
	# Store list of files in game folder.
	my @game_folder_files = folder_list($sd_path_source . "/" . $sd_subfolder);

	# Iterate through contents of game folder.
	foreach my $game_folder_file (@game_folder_files)
	{
		# Move each file into temporary folder.
		rename_until_free($sd_path_source . "/" . $sd_subfolder . "/" . $game_folder_file,
						  $sd_path_source . "/towns_sorter_temp/" . $sd_subfolder . "/" . $game_folder_file);
	}

	# Remove original game folder.
	rmdir($sd_path_source . "/" . $sd_subfolder);
}

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
	
	# List game files in temporary folder.	
	my @game_folder_files = folder_list($sd_path_source . "/towns_sorter_temp/" . $game_list{$folder_name});

	# Iterate through contents of temporary game folder.
	foreach my $game_folder_file (@game_folder_files)
	{
		# Move each file back from temporay game folder.
		rename_until_free($sd_path_source . "/towns_sorter_temp/" . $game_list{$folder_name} . "/" . $game_folder_file,
						  $sd_path_source . "/" . $sd_subfolder_new . "/" . $game_folder_file);
	}

	# Remove temporary game folder.
	rmdir($sd_path_source . "/towns_sorter_temp/" . $game_list{$folder_name});

	# Overwrite original folder name with new one.
	$game_list{$folder_name} = $sd_subfolder_new;
}

# Remove temporary folder.
rmdir($sd_path_source . "/towns_sorter_temp/");

# Write separate game list to root of SD card for user convenience.
my $game_list = "01 - MENU\n";

foreach my $folder_name (sort { lc($a) cmp lc($b) } keys %game_list)
{
	my $folder_number = $game_list{$folder_name};
	$game_list .= $folder_number . " - " . $folder_name . "\n";
}

# Write GameList.txt files.
write_file($sd_path_source . "/GameList.txt", $game_list);
write_file($sd_path_source . "/01/GameList.txt", $game_list);

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
		print "\nThe \"RunMe.bat\" script was not found in folder 01!\n";
	}
}

# Status message.
print "\nSD card processing complete!\n\n";
print "An index of disc images can be found in the following location:\n";
print $sd_path_source . "GameList.txt\n\n";
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

# Subroutine to return an array of all files or folders in a specified folder.
#
# 1st parameter - Full path of folder to list.
# 2nd parameter - If true, only return top-level folders (no recursion).
sub folder_list
{
	my $folder = $_[0];
	my $only_folders = $_[1] // 0;

	opendir(my $folder_handle, $folder) or die $!;
	my @entries = grep { !/^\./ } readdir($folder_handle);
	closedir($folder_handle);

	my @results;

	foreach my $entry (@entries)
	{
		my $full_path = $folder . "/" . $entry;

		if($only_folders)
		{
			push @results, $entry if(-d $full_path);
		}
		else
		{
			if(-f $full_path)
			{
				push @results, $entry;  # Just the file name
			}
			elsif(-d $full_path)
			{
				# Recursively add full paths for files in subfolders
				my @subfolder_files = folder_list($full_path);
				push @results, map { $entry . "/" . $_ } @subfolder_files;
			}
		}
	}

	return @results;
}

# Subroutine to attempt file move/rename with prompt to close any processes preventing access to
# it.
#
# 1st parameter - Full path of source file/folder.
# 2nd parameter - Full path to destination file/folder.
sub rename_until_free
{
	my $source = ($_[0] =~ s/\\{2,}/\\/gr);
	my $destination = $_[1];

	while(1)
	{
		return 1 if(rename $source, $destination);

		my $code = Win32::GetLastError();

		if($code == 32 || $code == 5 || $!{EACCES} || $!{EBUSY})
		{
			print "The following file/folder is open in one or more other programs:\n";
			print "   -> " . $source . "\n";
			print "Please terminate any processes preventing access and then press Enter.\n";

			<STDIN>;

			next;
		}

		die "Fatal error trying to move \"$source\" to \"$destination\":\n$!\n";
	}
}

# Subroutine to determine if two specified files are identical.
#
# 1st parameter - Full path of first file.
# 2nd parameter - Full path of second file.
sub files_are_identical
{
	my $file1 = $_[0];
	my $file2 = $_[1];

	my $size1 = -s $file1;
	my $size2 = -s $file2;

	return 0 if(!defined $size1 || !defined $size2);
	return 0 if($size1 != $size2);

	open(my $filehandle1, '<', $file1) or return 0;
	open(my $filehandle2, '<', $file2) or return 0;
	binmode $filehandle1;
	binmode $filehandle2;

	my $buffer1;
	my $buffer2;

	while (1)
	{
		my $read1 = read($filehandle1, $buffer1, 4096);
		my $read2 = read($filehandle2, $buffer2, 4096);

		# Both files reached EOF
		last if $read1 == 0 && $read2 == 0;

		# Mismatch in read length or content
		return 0 if $read1 != $read2;
		return 0 if $buffer1 ne $buffer2;
	}

	close($filehandle1);
	close($filehandle2);

	return 1;
}