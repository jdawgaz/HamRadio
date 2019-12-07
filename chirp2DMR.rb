#!/usr/bin/env ruby

# usage: chirp2DMR.rb DMRchannelfile Chirpfile outputfile
#
# what this does, is to read in the DMRfile, find the highest number, for the next sequential number
# then it reads in each line of the chirp file, parses what it needs to, and adds it the DMR array
# then it outputs the DMR array to the output file
#
# see below for descriptions and example lines of each of the files involved.
# this will explain what is going on to do the conversion

# Chirp file:
# "Location","Name","Frequency","Duplex","Offset","Tone","rToneFreq","cToneFreq","DtcsCode","DtcsPolarity","Mode","TStep","Skip","Comment","URCALL","RPT1CALL","RPT2CALL"

# 1,"SPSTN1",147.12,"+",0.6,"Tone",162.2,88.5,23,"NN","FM",5,,,,,

# Method
#   name = C[1]
#   rx = C[2]
#   tx = rx : 
#     if C[3] = "+" then add C[4] to rx
#     if C[3] = "-" then subtract C[4] from rx
#   if C[5] = "Tone" then tone = C[6]

#DMR file:

#No.,Channel Name,Receive Frequency,Transmit Frequency,Channel Type,Transmit Power,Band Width,CTCSS/DCS Decode,CTCSS/DCS Encode,Contact,Contact Call Type,Radio ID,Busy Lock/TX Permit,Squelch Mode,Optional Signal,DTMF ID,2Tone ID,5Tone ID,PTT ID,Color Code,Slot,Scan List,Receive Group List,TX Prohibit,Reverse,Simplex TDMA,TDMA Adaptive,Encryption Type,Digital Encryption,Call Confirmation,Talk Around,Work Alone,Custom CTCSS,2TONE Decode,Ranging,Through Mode,Digi APRS RX,Analog APRS PTT Mode,Digital APRS PTT Mode,APRS Report Type,Digital APRS Report Channel,Correct Frequency[Hz],SMS Confirmation,Exclude channel from roaming

#Method
#D[0] = next seq
#D[1] = name
#D[2] = rx
#D[3] = tx
#D[8] = tone
#All other fields are like the #258 line
#make sure to dup all those other ones, and then sub in the ones above
#make sure D[9] and D[11] are cloned

#258,Superstition,147.12,147.72,A-Analog,Turbo,25K,Off,162.2,World-wide,Group Call,K7AZJ,Off,Carrier,Off,1,1,1,Off,1,1,None,None,Off,Off,Off,Off,Normal Encryption,Off,Off,Off,Off,251.1,0,Off,Off,Off,Off,Off,Off,1,0,Off,off
#266,S 146.460,146.46,146.46,A-Analog,Turbo,25K,Off,Off,World-wide,Group Call,K7AZJ,Off,Carrier,Off,1,1,1,Off,1,1,None,None,Off,Off,Off,Off,Normal Encryption,Off,Off,Off,Off,251.1,0,Off,Off,Off,Off,Off,Off,1,0,Off,off

require 'csv'

def usage
  puts "usage: chirp2DMR dmrfile chirpfile outputfile"
  exit 0
end

def gethighnbr(a)
  # need a temp array to find the last number of column A
  # without disturbing the orginal DMR array
  t = []
  a.each { |r| t << r.dup }

  firstrow = t.shift
  tdary = t.select { |item| item[0].to_i < 4000 }
  tdary.sort! { |a,b| a[0].to_i <=> b[0].to_i }

  highval = tdary[-1][0].to_i + 1
end

ARGV.count < 3 ? usage : "Processing ..."

puts "reading DMR file : #{ARGV[0]}"
DMRary = CSV.read(ARGV[0])

puts "reading Chirp file : #{ARGV[1]}"
Cary = CSV.read(ARGV[1])

highval = gethighnbr(DMRary)
puts "Determine highest number to start with (excepting 4001 and 4002) : #{highval}"

# set up temp items
#258,Superstition,147.12,147.72,A-Analog,Turbo,25K,Off,162.2,World-wide,Group Call,K7AZJ,Off,Carrier,Off,1,1,1,Off,1,1,None,None,Off,Off,Off,Off,Normal Encryption,Off,Off,Off,Off,251.1,0,Off,Off,Off,Off,Off,Off,1,0,Off,off

puts "Creating #{ARGV[2]}"

callsign = DMRary[1][11]
tg = DMRary[1][9]

Cary.shift   # get rid of header

Cary.each { |crec|
  name = crec[1]
  rx = crec[2].to_f
  tx = rx 
  tone = 0.0

  if crec[3] == "+"
     tx += crec[4].to_f
     tx = tx.round(2)
  elsif crec[3] == "-"
    tx -= crec[4].to_f
    tx = tx.round(2)
  end
  if crec[5] = "Tone" 
    tone = crec[6].to_f
  end

  tempitem = [0,"",0.0,0.0,"A-Analog","Turbo","25K","Off","Off","","Group Call","","Off","Carrier","Off",1,1,1,"Off",1,1,"None","None","Off","Off","Off","Off","Normal Encryption","Off","Off","Off","Off",251.1,0,"Off","Off","Off","Off","Off","Off",1,0,"Off","off"]

  # D[0] = next seq
  # D[1] = name
  # D[2] = rx
  # D[3] = tx
  # D[8] = tone
  # All other fields are like the #258 line
  # make sure to dup all those other ones, and then sub in the ones above
  # make sure D[9] and D[11] are cloned (digital talkgroup, although not used, and persons callsign)

  tempitem[0] = highval
  tempitem[1] = name
  tempitem[2] = rx
  tempitem[3] = tx
  tempitem[8] = tone
  tempitem[9] = tg
  tempitem[11] = callsign

  highval += 1
  DMRary << tempitem
}

File.open(ARGV[2], "w") do |f|
  DMRary.each do |r|
    f.puts(r.to_csv)
  end
end
