module TMCM3110

using LibSerialPort

TMCM3110_PORTNAME = ""
const BAUTRATE = 9600

function encode_command(m_address, n_command, n_type, n_motor, value)
  m_address = UInt8( m_address % (1<<8) )
  n_command = UInt8( n_command % (1<<8) )
  n_type    = UInt8( n_type % (1<<8)    )
  n_motor   = UInt8( n_motor % (1<<8)   )
  value     = Int32( value )
  values = [ parse(UInt8, bits(value)[ 1+(8*(i-1)) : 8+(8*(i-1)) ] , 2) for i in 1:4]

  checksum  = UInt8( (m_address + n_command + n_type + n_motor + sum(values)) % (1<<8) )

  tmcl_bytes = [m_address, n_command, n_type, n_motor, values..., checksum]

  return tmcl_bytes
end

function decode_reply(reply)
  r_address  = UInt8( reply[1] )
  m_address  = UInt8( reply[2] )
  r_status   = UInt8( reply[3] )
  Int32(r_status) != 100 ? warn(STATUSCODES[Int(r_status)]) : nothing
  n_command  = UInt8( reply[4] )
  values     = [ UInt8(value) for value in reply[5:8] ]
  r_checksum = UInt8( reply[9] )
  checksum = UInt8( (r_address + m_address + r_status + n_command + sum(values)) % (1<<8) )
  value      = parse( UInt32, "$(bits(values[1]))$(bits(values[2]))$(bits(values[3]))$(bits(values[4]))" , 2 )
  value      = reinterpret(Int32, value)
  return value
end

STATUSCODES = ( 100 => "Succesfully executed, no error",
                    101 => "Command loaded into TMCL program EEPROM",
                      1 => "Wrong Checksum",
                      2 => "Invalid command",
                      3 => "Wrong type",
                      4 => "Invalid value",
                      5 => "Configuration EEPROM locked",
                      6 => "Command not available" )

COMMAND_NUMBERS = (      1 => "ROR",
                         2 => "ROL",
                         3 => "MST",
                         4 => "MVP",
                         5 => "SAP",
                         6 => "GAP",
                         7 => "STAP",
                         8 => "RSAP",
                         9 => "SGP",
                        10 => "GGP",
                        11 => "STGP",
                        12 => "RSGP",
                        13 => "RFS",
                        14 => "SIO",
                        15 => "GIO",
                        19 => "CALC",
                        20 => "COMP",
                        21 => "JC",
                        22 => "JA",
                        23 => "CSUB",
                        24 => "RSUB",
                        25 => "EI",
                        26 => "DI",
                        27 => "WAIT",
                        28 => "STOP",
                        30 => "SCO",
                        31 => "GCO",
                        32 => "CCO",
                        33 => "CALCX",
                        34 => "AAP",
                        35 => "AGP",
                        37 => "VECT",
                        38 => "RETI",
                        39 => "ACO"  )

AXIS_PARAMETER = (       0 => "target position",
                         1 => "actual position",
                         2 => "target speed",
                         3 => "actual speed",
                         4 => "max positioning speed",
                         5 => "max acceleration",
                         6 => "abs max current",
                         7 => "standby current",
                         8 => "target pos reached",
                         9 => "ref switch status",
                        10 => "right limit switch status",
                        11 => "left limit switch status",
                        12 => "right limit switch disable",
                        13 => "left limit switch disable",
                       130 => "minimum speed",
                       135 => "actual acceleration",
                       138 => "ramp mode",
                       140 => "microstep resolution",
                       141 => "ref switch tolerance",
                       149 => "soft stop flag",
                       153 => "ramp divisor",
                       154 => "pulse divisor",
                       160 => "step interpolation enable",
                       161 => "double step enable",
                       162 => "chopper blank time",
                       163 => "chopper mode",
                       164 => "chopper hysteresis dec",
                       165 => "chopper hysteresis end",
                       166 => "chopper hysteresis start",
                       167 => "chopper off time",
                       168 => "smartEnergy min current",
                       169 => "smartEnergy current downstep",
                       170 => "smartEnergy hysteresis",
                       171 => "smartEnergy current upstep",
                       172 => "smartEnergy hysteresis start",
                       173 => "stallGuard2 filter enable",
                       174 => "stallGuard2 threshold",
                       175 => "slope control high side",
                       176 => "slope control low side",
                       177 => "short protection disable",
                       178 => "short detection timer",
                       179 => "Vsense",
                       180 => "smartEnergy actual current",
                       181 => "stop on stall",
                       182 => "smartEnergy threshold speed",
                       183 => "smartEnergy slow run current",
                       193 => "ref. search mode",
                       194 => "ref. search speed",
                       195 => "ref. switch speed",
                       196 => "distance end switches",
                       204 => "freewheeling",
                       206 => "actual load value",
                       208 => "TMC262 errorflags",
                       209 => "encoder pos",
                       210 => "encoder prescaler",
                       212 => "encoder max deviation",
                       214 => "power down delay"    )

INTERRUPT_VECTORS = (  0 => "Timer 0",
                           1 => "Timer 1",
                           2 => "Timer 2",
                           3 => "Target position 0 reached",
                           4 => "Target position 1 reached",
                           5 => "Target position 2 reached",
                          15 => "stallGuard2 axis 0",
                          16 => "stallGuard2 axis 1",
                          17 => "stallGuard2 axis 2",
                          21 => "Deviation axis 0",
                          22 => "Deviation axis 1",
                          23 => "Deviation axis 2",
                          27 => "Left stop switch 0",
                          28 => "Right stop switch 0",
                          29 => "Left stop switch 1",
                          30 => "Right stop switch 1",
                          31 => "Left stop switch 2",
                          32 => "Right stop switch 2",
                          39 => "Input change 0",
                          40 => "Input change 1",
                          41 => "Input change 2",
                          42 => "Input change 3",
                          43 => "Input change 4",
                          44 => "Input change 5",
                          45 => "Input change 6",
                          46 => "Input change 7",
                         255 => "Global interrupts" )

function get_axis_parameter(serialport, n_axisparameter, n_motor)
  clear_input_buffer(serialport)
  command = TMCM3110.encode_command(1,6,n_axisparameter, n_motor, 0)
  write(serialport, command)
  sleep(0.02)# you have to give the controller time to respond
  if nb_available(serialport) < 9
    error("No response from controller.")
    nothing
  elseif nb_available(serialport) > 9
    info("Input buffer overloaded: clearing...")
    nothing
  else
    reply = TMCM3110.decode_reply(readbytes!(serialport,9))
  end
  return reply
end

function set_axis_parameter(serialport, n_axisparameter, n_motor, value)
  command = TMCM3110.encode_command(1,5,n_axisparameter, n_motor, value)
  write(serialport, command)
  sleep(0.02)# you have to give the controller time to respond
  println( get_axis_parameter(serialport, n_axisparameter, 0) )
  nothing
end

function store_axis_parameter_permanent(serialport, n_axisparameter, n_motor, value)
  # first set the new value
  command = TMCM3110.encode_command(1,5,n_axisparameter, n_motor, value)
  write(serialport, command)
  sleep(0.02)
  # then store it permanent
  command = TMCM3110.encode_command(1,7,n_axisparameter, n_motor, 0)
  write(serialport, command)
  sleep(0.02)# you have to give the controller time to respond
  # check it
  println( get_axis_parameter(serialport, n_axisparameter, 0) )
  nothing
end

function clear_input_buffer(serialport)
  readbytes!(serialport,nb_available(serialport))
  nothing
end

function get_portname_of_TMCM3110( ;nports_guess::Integer=64)
  global TMCM3110_PORTNAME=""
  # basically a copy from the function LibSerialPort.list_ports()
  ports = sp_list_ports()
  for port in unsafe_wrap(Array, ports, nports_guess, false)
      port == C_NULL && return
      # println(sp_get_port_name(port))
      # println("\tDescription:\t",    sp_get_port_description(port))
      # println("\tTransport type:\t", sp_get_port_transport(port))
      if ismatch(r"Stepper Device - TMCSTEP", sp_get_port_description(port) )
        TMCM3110_PORTNAME = sp_get_port_name(port)
        info("TMCM-3110 found: \"$TMCM3110_PORTNAME\"")
      end
  end
  sp_free_port_list(ports)
  return nothing
end

function list_all_axis_parameters(serialport)
  for (key,value) in TMCM3110.AXIS_PARAMETER # wrong oder
    axis_parameters = Any[0,0,0]
    for i in 1:3
      try
        axis_parameters[i] = get_axis_parameter(serialport, key, i-1)
      catch err
        warn("$err")
        axis_parameters[i] = "ERROR"
      end
    end
    if length(value) <= 12
      info("$key  \t- $value:\t\t\t$(axis_parameters[1])\t\t$(axis_parameters[2])\t\t$(axis_parameters[3])")
    elseif 12 < length(value) <= 20
      info("$key  \t- $value:\t\t$(axis_parameters[1])\t\t$(axis_parameters[2])\t\t$(axis_parameters[3])")
    else
      info("$key  \t- $value:\t$(axis_parameters[1])\t\t$(axis_parameters[2])\t\t$(axis_parameters[3])")
    end
  end
  return nothing
end

end # module
