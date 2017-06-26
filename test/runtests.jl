using TMCM3110
using Base.Test

using LibSerialPort

const BAUTRATE = 9600

smc = LibSerialPort.open_serial_port("/dev/ttyACM1", BAUTRATE)

function get_axis_parameter(serialport, n_axisparameter, n_motor)
  clear_input_buffer(serialport)
  command = TMCM3110.encode_command(1,6,n_axisparameter, n_motor, 0)
  write(serialport, command)
  sleep(0.01)# you have to give the controller time to respond
  println(nb_available(serialport))
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

function clear_input_buffer(serialport)
  readbytes!(serialport,nb_available(serialport))
  nothing
end

function mytest()
  k = 1
  while k <= 10
    info("k: $k / 10")
    println( get_axis_parameter(smc, 209,0) )
    sleep(1)
    k+=1
  end
  return 0
end

mytest()
