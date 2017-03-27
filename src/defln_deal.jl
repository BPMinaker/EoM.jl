function defln_deal!(the_system,static,verb)
## Copyright (C) 2017 Bruce Minaker
## defln_deal.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## defln_deal.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------


verb && println("Distributing deflections...")

for i in the_system.bodys[1:end-1]
	i.deflection=static[1:3]
	i.angular_deflection=static[4:6]
	static=circshift(static,-6)
end

end ## Leave
