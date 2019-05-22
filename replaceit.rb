#!/usr/bin/ruby
require "fileutils"
require "shellwords"

#Check

if ARGV.length != 1
  puts "Usage: ruby replaceit from to path. Example: ruby replaceit /Users/you/thedir"
  exit
end

# Configurations

# For replacing occurences from -> to
from = "foo"
to = "bar"

# For checking if a file contains one of this words
strings_to_match = ["foo", "bar", "zoo"]

# For adding a line on top of a file

content_to_append = "new line at top"


target_folder_path = ARGV[0]

# Functions

def isText(filename)
	escaped_filename = filename.shellescape
	output = `file -b --mime-type #{escaped_filename} | sed 's|/.*||'`
  	return output =~ /text/i
end

def replace(string, substring, replacement)
	replaced = string.gsub(/#{substring}/i, replacement)
  	return replaced
end

def content_of_file_contains_string(content, string)
	return content =~ /#{string}/i
end

def append_content_on_top_of_file(file_path, content)
	f = File.open(file_path, "r+")
	lines = f.readlines
	f.close
	lines = [content] + ["\n"] + lines
	output = File.new(file_path, "w")
	lines.each { |line| output.write line }
	output.close
end

def content_of_file_contains_multiple_strings(content, listOfStrings)
	listOfStrings.any? { |string| content.include?(string) }
end

def replaceIfMatching(string, replacements, ignore)
	replacements.map { |substring, replacement|
  		string_contains_substring = string =~ /#{substring}/i
  		string_already_contains_sc = string =~ /#{ignore}/i
  		if string_contains_substring && !string_already_contains_sc
  			string = replace(string, substring, replacement)
  		end
	}
	return string
end

def replaceContentOfFileIfMatching(content, replacements, ignore)
	new_content = replaceIfMatching(content, replacements, ignore)
	if new_content != content
		puts "replacing occurences in file #{file}"
		File.open(file, "w") { |file| file.puts new_content }
	end
end

# Script

puts("\n\n*** Starting replacing it! *** \n\n")

replacements = { from => to} 

Dir.glob(target_folder_path + "/**/*") do |file|
	is_file_relevant = File.extname(file) == ".m" || File.extname(file) == ".h"
	if is_file_relevant
		content = File.read(file)
					
		file_matches_strings = content_of_file_contains_multiple_strings(content, strings_to_match)
		if file_matches_strings
			puts("\n\n file: " + file + " contains one of: " + strings_to_match.inspect)
			append_content_on_top_of_file(file, content_to_append)
		end
	end
end

