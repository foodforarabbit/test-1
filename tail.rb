# tail.rb
# author: Ryan Wong (r25wong@gmail.com)
# requirements: tested with ruby 2.4.0
#
# usage:
# ruby tail.rb [OPTION]... [FILE]...
#
# help:
# ruby tail.rb -h
#
# example usage:
# ruby tail.rb -n 20 test1.txt
#
# tests:
# ruby tail_test.rb

require 'optparse'


# use handy ruby optparse to parse flags
options = {}
OptionParser.new do |opts|
  # message when given -h flag
  opts.banner = "Usage: ruby tail.rb [OPTION]... [FILE]..."

  # debug output
  opts.on("-d", "--debug", "Debug output") do |d|
    options[:debug] = d
  end

  # -n, --lines=K flag
  opts.on("-n", "--lines=K", Integer, "Output the last K lines, instead of the default of the last 10; alternatively, use \"-n +K\" to output lines starting with the Kth.") do |k|
    options[:lines] = k
  end
end.parse!

# set default for :lines option to 10
options[:lines] ||= 10

# output some useful info if debugging
if options[:debug]
  p options
  p ARGV
end

# read from the back, how much to read at a time
SEEK_AMOUNT = 65536

if options[:lines] != nil
  # remaining arguments are assumed to be filenames.
  ARGV.each do |filename|
    begin
      f1 = File.open(filename)

      if f1.size <= SEEK_AMOUNT # if the file is smaller than SEEK_AMOUNT, read the whole thing at once
        f1buffer = f1.readlines.last(options[:lines])
        puts f1buffer
      else # otherwise, seek to the end and keep adding text to the buffer until we have enough lines
        seek_amount = SEEK_AMOUNT

        # seek to the position where we want to start reading from
        # i.e. seek_amount from the end of the file
        f1.seek(-seek_amount, :END)

        # initialize buffer
        f1buffer = ""

        # keep looping until we have enough "\n" in the buffer
        while f1buffer.count("\n") <= options[:lines]

          # read from position, seek_amount amount, a prepend to buffer
          f1buffer = f1.read(seek_amount) + f1buffer

          # read moves the position forward, so we need to move it back to where we "started"
          f1.seek(-seek_amount, :CUR)

          # if current position is less than seek_amount, we just read the rest and exit the loop
          # we might not have enough lines, but that is ok
          if f1.tell <= seek_amount
            tell = f1.tell
            f1.seek(-tell, :CUR)
            f1buffer = f1.read(tell) + f1buffer
            break
          else # otherwise, move position further along and prepare for another read
            f1.seek(-seek_amount, :CUR)
          end
        end
        # when we split the buffer by \n, we want to add \n back in to each line to produce identical output to File.readlines above
        puts f1buffer.split("\n").last(options[:lines]).map{|x| "#{x}\n"}
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end
