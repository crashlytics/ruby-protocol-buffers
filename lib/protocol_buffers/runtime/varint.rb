module ProtocolBuffers

  module VarintPure # :nodoc:
    def encode(io, int_val)
      if int_val < 0
        # negative varints are always encoded with the full 10 bytes
        int_val = int_val & 0xffffffff_ffffffff
      end
      loop do
        byte = int_val & 0b0111_1111
        int_val >>= 7
        if int_val == 0
          io << byte.chr
          break
        else
          io << (byte | 0b1000_0000).chr
        end
      end
    end

    def decode(io)
      int_val = 0
      shift = 0
      loop do
        raise(DecodeError, "too many bytes when decoding varint") if shift >= 64
        # this works in 1.8.7 and 1.9.x, but for different reasons
        # in 1.8.7 io.getc returns the int representation of the char, and .ord is a noop. String#ord doesn't exist.
        # in 1.9.3 io.getc returns a String, and .ord returns the int representation of the first char.
        # this fails in 1.8.6, which is no longer supported by ruby-protocol-buffers.
        byte = io.getc.ord
        int_val |= (byte & 0b0111_1111) << shift
        shift += 7
        return int_val if (byte & 0b1000_0000) == 0
      end
    end
  end

  class Varint
    def self.encodeZigZag32(int_val)
      (int_val << 1) ^ (int_val >> 31)
    end

    def self.encodeZigZag64(int_val)
      (int_val << 1) ^ (int_val >> 63)
    end

    def self.decodeZigZag32(int_val)
      (int_val >> 1) ^ -(int_val & 1)
    end

    class << self
      alias_method :decodeZigZag64, :decodeZigZag32
    end
  end

end

# optionally load C extension
begin
  require 'varint/varint'
  class ProtocolBuffers::Varint
    extend ::Varint
  end
rescue LoadError
  class ProtocolBuffers::Varint
    extend ::ProtocolBuffers::VarintPure
  end
end
