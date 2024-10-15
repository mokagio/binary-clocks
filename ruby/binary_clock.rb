require 'io/console'

def clear_screen
  system('clear')
end

def to_binary(number:, bits:)
  number.to_s(2).rjust(bits, '0').chars.map(&:to_i)
end

def to_4_bit_binary_zero_padded(number:)
  number.to_s.rjust(2, '0').chars.map { |c| to_binary(number: c.to_i, bits: 4) }
end

def binary_time_representation(time:, zero:, one:, spacer_string:, empty_string:)
  # 18 will become [[0,0,0,1],[1,0,0,0]]
  hours = to_4_bit_binary_zero_padded(number: time.hour)
  minutes = to_4_bit_binary_zero_padded(number: time.min)
  seconds = to_4_bit_binary_zero_padded(number: time.sec)

  # Because of the ordering of the digits array (see example above), we start from position 0 and finish at position 3
  lines = [
    [nil, hours.last[0], nil, minutes.last[0], nil, seconds.last[0]],
    [nil, hours.last[1], minutes.first[1], minutes.last[1], seconds.first[1], seconds.last[1]],
    [hours.first[2], hours.last[2], minutes.first[2], minutes.last[2], seconds.first[2], seconds.last[2]],
    [hours.first[3], hours.last[3], minutes.first[3], minutes.last[3], seconds.first[3], seconds.last[3]]
  ].map do |line|
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
        #{binary_time_representation(time: Time.now, zero:, one:, spacer_string:, empty_string:)}
      OUT

      # Use IO.select to check if input is available without blocking
      if IO.select([IO.console], nil, nil, 0.1)
        input = STDIN.getch rescue nil
        puts input
        break if input == 'q'
      end

      # sleep less than one second to avoid edge case when the tick is at the
      # second change and you go from s to s+2
      sleep 0.2
    end
  ensure
    clear_screen
    puts "Exiting Binary Clock. Goodbye!"
  end
end

mode = :emoji

case mode
when :ascii
	print_binary_clock(zero: 'X', one: '0', spacer_string: ' ', empty_string: ' ')
when :emoji
	# Rendering emojis results in different spaces, so we need an emoji for the empty case to keep alignment
	print_binary_clock(zero: '⚫️', one: '🟢', spacer_string: ' ', empty_string: '⚫️', show_header: false)
else
	raise "Invalid mode #{mode}"
end

