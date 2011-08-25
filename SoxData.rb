=begin
This class will take a .dat format output file from SoX
and extract the amplitude values - these are stored in the
@amplitudes array.

Methods for granular amplification/resynthesis are provided
to support feature-detection.

'Slot' is intended to be used for internal representation of granules.
'Granule' is intended to be used for external representation (i.e. what the programmer using this sees. In truth, this is probably not necessary and might be
refactored out in the near future.
=end

class SoxData
  def initialize(filename, slotSize)
    @slotSize = slotSize # Width of a granule
    f = File.open(filename, "r")
    text = f.read
    time_amplitude_pairs = Array.new
    # Ignore header lines and read time-amplitude pairs into an array
    text.lines { |x| if (x[0].chr != ";") then time_amplitude_pairs << x end }
    @amplitudes = Array.new
    # Extract the amplitude from each pair and add to @amplitudes array
    time_amplitude_pairs.each { |x| @amplitudes << x.split(%r{\s+})[2].to_f }
    f.close
  end

  # Write the amplitudes only to a file
  def write(filename)
    f = File.open(filename, "w")
    @amplitudes.each { |x| f.puts(x) }
    f.close
  end

  def amplitudes
    @amplitudes
  end

  def slotSize
    @slotSize
  end

  # Get a granule of the specified length, starting from the specified position
  def granule(startPos, length)
    @amplitudes[startPos..startPos+length-1]
  end

  # Break up @amplitudes into segments with the specified length
  def segments(length)
    segments = Array.new
    numSegments = @amplitudes.length / length
    # Outer loop deals with whole segments
    for i in (0...numSegments)
      tempSegment = Array.new
      # Inner loop constructs a single segment
      for j in (0...length)
	    tempSegment << @amplitudes[i+j]
      end
      segments << tempSegment # Add the constructed segment to the segments array
    end
    segments
  end

  # Additive synthesis - add the given granule at the specified position
  def addGranule(granule, startPos)
    # Slice the @amplitudes array at the appropriate point, zip the slice
    # and the given granule together and deal with nil values (which result
    # when granule has a different length than slotSize
    @amplitudes[startPos..startPos+slotSize-1] = @amplitudes[startPos..startPos+slotSize-1].zip(granule).map { |pair| pair[0] + (pair[1].nil? ? 0.0 : pair[1]) }
  end

  # Work out the absolute position in @amplitudes of a given slot
  def slot(slotNum)
    slotNum * @slotSize
  end
end

