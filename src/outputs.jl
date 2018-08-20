function outputs!(the_system,data,verb)
## Copyright (C) 2017, Bruce Minaker
## outputs.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## outputs.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Generates the Jacobian output matrix for the sensors
verb && println("Building output matrix...")

nin=length(the_system.actuators)
nout=length(the_system.sensors)
d_mtx=zeros(nout,nin)

n=length(the_system.bodys)

sensor_mtx=-diagm(0=>broadcast(gain,the_system.sensors))*point_line_jacobian(the_system.sensors,n)

order_vec=broadcast(order,the_system.sensors)
frame_vec=broadcast(frame,the_system.sensors)

column=2*order_vec+frame_vec.-2  ## Global psn,vel,acc=1,3,5, local vel,acc=2,4

idx=1
for i in the_system.sensors
	if(i.actuator_number>0)
		d_mtx[idx,i.actuator_number]=-i.gain
	end
	idx+=1
end

data.output=sensor_mtx
data.feedthrough=d_mtx

column

end ## Leave
