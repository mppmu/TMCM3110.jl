module TMCM3110

function encode_command(m_address, n_command, n_type, n_motor, value)
  m_address = UInt8( m_address % (1<<8) )
  n_command = UInt8( n_command % (1<<8) )
  n_type    = UInt8( n_type % (1<<8)    )
  n_motor   = UInt8( n_motor % (1<<8)   )
  value     = [ UInt8( (value >> i*8) % (1<<8) ) for i in range(3,-1,4)]

  checksum = UInt8( (m_address + n_command + n_type + n_motor + sum(value)) % (1<<8) )

  tmcl_bytes = [m_address, n_command, n_type, n_motor, value..., checksum]
  # tmcl_cmd = sum(Int128(b) << (9-i)*8 for (i,b) in enumerate(tmcl_bytes))


  command = String(transcode(UInt8, tmcl_bytes));
  return command
end

function decode_reply(reply)
  reply = Vector{UInt8}(reply)
  reply = Vector{Int}(reply)
  return reply
end

# test
end # module
