require 'io/console'

def clear_screen
  system('clear')
end

def to_binary(number:, bits:)
  number
    .to_s(2) # convert to binary (base 2)
    .rjust(bits, '0') # make sure the string has as many bits are requested
    .chars.map(&:to_i) # return an array of int digits (could also be bool)
end

def to_4_bit_binary(number:)
  number
    .to_s # convert to string for the next operation
    .rjust(2, '0') # zero-pad so we always have two digits
    .chars
    .map { |c| to_binary(number: c.to_i, bits: 4) } # convert the two digits (chars) to 4-bit binary
end

def binary_clock_digits(time:)
  # 18 will become [1, 8], then [[0,0,0,1],[1,0,0,0]]
  hours = to_4_bit_binary(number: time.hour)
  minutes = to_4_bit_binary(number: time.min)
  seconds = to_4_bit_binary(number: time.sec)

  # Because of the ordering of the digits array (see example above), we start from position 0 and finish at position 3
  [
    [nil, hours.last[0], nil, minutes.last[0], nil, seconds.last[0]],
    [nil, hours.last[1], minutes.first[1], minutes.last[1], seconds.first[1], seconds.last[1]],
    [hours.first[2], hours.last[2], minutes.first[2], minutes.last[2], seconds.first[2], seconds.last[2]],
    [hours.first[3], hours.last[3], minutes.first[3], minutes.last[3], seconds.first[3], seconds.last[3]]
  ]
end

def to_binary_clock_multiline_string(time:, zero:, one:, spacer_string:, empty_string:)
  binary_clock_digits(time: time).map do |line|
    line.map do |char|
      if char.nil?
        empty_string
      else
        char == 0 ? zero : one
      end
    end.join(spacer_string)
  end.join("\n")
end

def print_binary_clock(zero:, one:, spacer_string:, empty_string:, show_header: true)
  header = <<~HEADER
    Binary Clock (Press 'q' then 'Enter' to quit)

  HEADER

  begin
    loop do
      clear_screen

      # TODO: Make it press only q; or make it press any key

      puts header if show_header

      puts <<~OUT
        #{to_binary_clock_multiline_string(time: Time.now, zero:, one:, spacer_string:, empty_string:)}
      OUT

      # Use IO.select to check if input is available without blocking
      if IO.select([IO.console], nil, nil, 0.1)
        input = STDIN.getch rescue nil
        puts input
        break if input == 'q'
      end

      # Sleep less than one second to avoid edge case when the tick is at the
      # second change and you go from s to s+2
      sleep 0.2
    end
  ensure
    clear_screen
    puts "Exiting Binary Clock. Goodbye!"
  end
end

mode = :ascii

case mode
when :ascii
	print_binary_clock(zero: '0', one: 'X', spacer_string: ' ', empty_string: ' ')
when :emoji
	# Rendering emojis results in different spaces, so we need an emoji for the empty case to keep alignment
	print_binary_clock(zero: '⚫️', one: '🟢', spacer_string: ' ', empty_string: '⚫️', show_header: false)
else
	raise "Invalid mode #{mode}"
end
