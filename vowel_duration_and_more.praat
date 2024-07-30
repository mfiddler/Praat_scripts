##	This script takes a TextGrid as input and retrieves all the (non-null) labels of the intervals marked 
##	in the specified tier and their duration, along with other information from the other tiers in the TextGrid.  
##	It outputs a log file called "duration-log.txt" in the same directory as the TextGrid files.

##	More specifically, it was written to run on a transcript of a conversation between two speakers, 
## 	with the following tier structure:
## 	Tier 1: (not used in this script) annotation of intonational boundary tones
##	Tier 2: Speaker 1, segmented into Intonation Units (phrases, sentences, whatever unit you prefer)
##	Tier 3: Speaker 2, segmented into Intonation Units
##	Tier 4: words (you could segment all the words if you want, or selected words of interest)
##	Tier 5: smoothness (annotation of whether the word was produced smoothly or with hesitation)
##	Tier 6: phrasing (annotation of whether the word was its own Accentual Phrase or grouped with a word before or after)
##	Tier 7: vowel (segmentation of individual vowels in the target words)

## Each row of the output includes the following information for each vowel, with tab stops between each item for easy conversion to a spreadsheet/dataframe:
##		Filename
##		Speaker
## 		Word
##		Word start time
##		Vowel (the label from the segmented interval)
##		Vowel start time
##		Vowel end time
## 		Vowel duration
##		Smoothness
##		Phrasing
##		Text of the Intonational Phrase the word came from
##		Intonational Phrase start time
##		Intonational Phrase end time
##		Intonational Phrase duration
##		Distance between start of the IP and start of the target word (in ms)
##		Distance between end of the target word and end of the IP (in ms)



##  Specify the directory containing your textgrid files in the next line:

directory$ = "/Users/michael/Documents/AAA_UCSB/Dissertation/Chapter2/test/"

##  Delete any pre-existing variant of the log:

filedelete 'directory$'duration-log.txt

##  Make a variable called "header_row$", then write that variable to the log file:

header_row$ = "FILE" + tab$ + "SPEAKER" + tab$ + "WORD" + tab$ + "WORD_START_TIME" + tab$ + "VOWEL_LABEL" + tab$ + "VOWEL_START_TIME" + tab$ + "VOWEL_END_TIME" + tab$ + "VOWEL_DURATION" + tab$ + "SMOOTHNESS" + tab$ + "PHRASING" + tab$ + "IP" + tab$ + "IP_START_TIME" + tab$ + "IP_END_TIME" + tab$ + "IP_DURATION" + tab$ + "DISTANCE_FR_START" + tab$ + "DISTANCE_FR_END" + newline$
header_row$ > 'directory$'duration-log.txt

##  Make a list of all the text grids in the directory we're using, and put the number of
##  filenames into the variable "number_of_files":

Create Strings as file list...  list 'directory$'*.TextGrid
number_files = Get number of strings

# Then we set up a loop that will iterate over all the files in the list:

for j from 1 to number_files

     # Query the file-list to get the first filename from it, then read that file in:

     select Strings list
     current_token$ = Get string... 'j'
     Read from file... 'directory$''current_token$'

     # Here we make a variable called "file_name$" that will be equal to the filename minus the ".wav" extension:
     file_name$ = selected$ ("TextGrid")

     # Now we figure out how many intervals there are in the tier with the vowels labeled, and step through them one at a time.
     # If an interval's label is non-null, we get its duration and other data, and write it to the log file. 

	  # start on the tier with vowels segmented and labeled (here, tier 7)
     number_of_intervals = Get number of intervals... 7
     for b from 1 to number_of_intervals
          vowel_label$ = Get label of interval... 7 'b'

          # Find the intervals representing vowels (ie the ones that are labeled)
			if vowel_label$ <> ""
				
				vowel_start_time = Get starting point... 7 'b'
              vowel_end_time = Get end point... 7 'b'
				vowel_duration = vowel_end_time - vowel_start_time	
				midpoint = vowel_start_time + (vowel_duration / 2)

				# make sure the smoothness tier is labeled (here, tier 5)
				smoothness_interval = Get interval at time: 5, midpoint
				smoothness_label$ = Get label of interval... 5 'smoothness_interval'
				
				#if the smoothness tier is labeled, then we proceed with the rest of the script
				if smoothness_label$ <> ""

					# we already have the vowel duration from the calculation above (vowel_duration)

					# get the labels from the smoothness and phrasing tiers
					# we already have smoothness from above
					smoothness$ = smoothness_label$

					phrasing_interval = Get interval at time: 6, midpoint
					phrasing$ = Get label of interval... 6 'phrasing_interval'

					# This is for adding the word label and start time for the current vowel
					# First, get the index of the interval at the midpoint of the tagged item, on the tier with the target words labeled
					word_interval = Get interval at time: 5, midpoint 
				
					# Now get the string of text (if any) on the word tier at that point in time 
              	word$ = Get label of interval: 4, word_interval
	
					# And get the starting point of the word
					word_start_time = Get starting point... 4 'word_interval'	


					# This is for adding the speaker and the text of the IP/IU at the time of the tagged item
					# First, get the index of the interval at the midpoint of the tagged item, on tier 2 (Speaker 1)
					interval_speaker1 = Get interval at time: 2, midpoint 
				
					# Then, get the string of text (if any) from Speaker 1 at that point in time 
             		speaker1_IP$ = Get label of interval: 2, interval_speaker1
	
					# Now get the index of the interval at the midpoint of the tagged item, on tier 3 (Speaker 2)  
					interval_speaker2 = Get interval at time: 3, midpoint 
				
					# And get the string of text (if any) from Speaker 2 at that point in time 
 					speaker2_IP$ = Get label of interval: 3, interval_speaker2 

					# Check to see who's actually talking, and get that speaker's name (i.e. the name of the tier named for that speaker)
					# If there is text only in Speaker 1's interval
					if speaker1_IP$ <> "" and speaker2_IP$ = ""
						# then speaker$ is the name of Speaker 1's tier
						speaker$ = Get tier name... 2 
						# and ip$ is the text from that interval in Speaker 1's tier
						ip$ = speaker1_IP$	
					
						ip_start_time = 	Get starting point... 2 'interval_speaker1'
						ip_end_time = Get end point... 2 'interval_speaker1'
						# treating ip_duration as a string bc the "check" in the 'else' part of the loop has to be a string
						ip_duration$ = string$(ip_end_time - ip_start_time)
						distance_fr_start$ = string$(vowel_start_time - ip_start_time)
						distance_fr_end$ = string$(ip_end_time - vowel_end_time)					

					# And if there is text only in Speaker 2's interval
					elsif speaker1_IP$ = "" and speaker2_IP$ <> "" 
						# then speaker$ is the name of Speaker 2's tier
						speaker$ = Get tier name... 3
						# and ip$ is the text from that interval in Speaker 2's tier
						ip$ = speaker2_IP$	
					
						ip_start_time = 	Get starting point... 3 'interval_speaker2'
						ip_end_time = Get end point... 3 'interval_speaker2'
						ip_duration$ = string$(ip_end_time - ip_start_time)
						distance_fr_start$ = string$(vowel_start_time - ip_start_time)
						distance_fr_end$ = string$(ip_end_time - vowel_end_time)

			 	
					# But if they're both talking, or if for some reason neither is talking
					else 
						speaker$ = "check"
						ip$ = "check"
						ip_duration$ = "check"
						distance_fr_start$ = "check"
						distance_fr_end$ = "check"
					
					#close the conditional for speaker stuff
					endif		


             fileappend "'directory$'duration-log.txt" 'file_name$' 'tab$' 'speaker$' 'tab$' 'word$' 'tab$' 'word_start_time' 'tab$' 'vowel_label$' 'tab$' 'vowel_start_time' 'tab$' 'vowel_end_time' 'tab$' 'vowel_duration' 'tab$' 'smoothness$' 'tab$' 'phrasing$' 'tab$' 'ip$' 'tab$' 'ip_start_time' 'tab$' 'ip_end_time' 'tab$' 'ip_duration$' 'tab$' 'distance_fr_start$' 'tab$' 'distance_fr_end$' 'newline$'
          
				# close the conditional for smoothness label
				endif	

			# close the conditional for vowel duration interval
			endif

	  # close the loop over the intervals on the vowel tier
     endfor

     # get rid of any objects we no longer need, and end our for loop

     select all
     minus Strings list
     Remove
endfor


# Clean up and confirm that the files were processed successfully.

select all
Remove
clearinfo
print All files have been processed.  What next?
