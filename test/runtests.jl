using TMCM3110
using Base.Test

using LibSerialPort

TMCM3110_PORTNAME = ""
const BAUTRATE = 9600

function get_portname_of_TMCM3110(;nports_guess::Integer=64)
  # basically a copy from the function LibSerialPort.list_ports()
  ports = sp_list_ports()
  for port in unsafe_wrap(Array, ports, nports_guess, false)
      port == C_NULL && return
      # println(sp_get_port_name(port))
      # println("\tDescription:\t",    sp_get_port_description(port))
      # println("\tTransport type:\t", sp_get_port_transport(port))
      if ismatch(r"Stepper Device - TMCSTEP", sp_get_port_description(port) )
        global TMCM3110_PORTNAME
        TMCM3110_PORTNAME = sp_get_port_name(port)
        info("TMCM-3110 found: \"$TMCM3110_PORTNAME\"")
      end
  end
  sp_free_port_list(ports)
  return nothing
end



function test_get_axis_parameter(serialport)
  for (key,value) in TMCM3110.AXIS_PARAMETER # wrong oder
    axis_parameter = "unknown"
    try
      axis_parameter = get_axis_parameter(serialport, key, 0)
    catch err
      error("ERROR: $err")
      axis_parameter = "ERROR"
    end
    if length(value) <= 12
      info("$key  \t- $value:\t\t\t$axis_parameter")
    elseif 12 < length(value) <= 20
      info("$key  \t- $value:\t\t$axis_parameter")
    else
      info("$key  \t- $value:\t$axis_parameter")
    end
  end
  return nothing
end

get_portname_of_TMCM3110()

if (TMCM3110_PORTNAME == "")
  info("TMCM-3110 not found.")
else
  smc = LibSerialPort.open_serial_port(TMCM3110_PORTNAME, BAUTRATE)
  test_get_axis_parameter(smc)
end
