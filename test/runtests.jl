using Base.Test

using TMCM3110

TMCM3110.get_portname_of_TMCM3110()
#smc = LibSerialPort.open_serial_port(TMCM3110.TMCM3110_PORTNAME, TMCM3110.BAUTRATE)


if (TMCM3110.TMCM3110_PORTNAME == "")
  info("TMCM-3110 not found.")
else
  info("TMCM-3110 found. Portname: $(TMCM3110.TMCM3110_PORTNAME)")
  smc = LibSerialPort.open_serial_port(TMCM3110.TMCM3110_PORTNAME, TMCM3110.BAUTRATE)
  TMCM3110.list_all_axis_parameters(smc)
end
