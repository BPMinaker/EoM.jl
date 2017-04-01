function tex_bode3_pgfplot(ins,outs)
## Copyright (C) 2017, Bruce Minaker
## tex_bode_pgfplot.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## tex_bode_pgfplot.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

nin=length(ins)
nout=length(outs)
s="\\section{Frequency Response Plots}\n"

for i=1:nin  ## For each input-output pair
	for j=1:nout
		s*="\\begin{figure}[hbtp]\n"
		s*="\\begin{center}\n"
		s*="\\begin{footnotesize}\n"
		s*="\\pgfplotsset{colormap={windsor}{color=(gray) color=(white) color=(gray)}}\n"
		s*="\\pgfplotsset{tick label style={font=\\scriptsize},label style={font=\\scriptsize},title style={font=\\small},xminorticks={false}}\n"
		s*="\\begin{tikzpicture}\n"
		s*="\\begin{semilogxaxis}[height=3in,width=4in,tick style={thin,black},view={45}{45},xlabel={Frequency [Hz]},ylabel={Speed [m/s]},zlabel={Transfer Function [dB]},enlargelimits=false,xlabel style={sloped like x axis}, ylabel style={sloped like y axis}]\n"
		s*="\\addplot3[surf] table[x=frequency,y=speed,z=m$((i-1)*nout+j)]{bode.out};\n"
		s*="\\end{semilogxaxis}\n"
		s*="\\end{tikzpicture}\n"
		s*="\\end{footnotesize}\n"
		s*="\\caption{Frequency response: $(outs[j]) / $(ins[i])}\n"
		s*="\\label{bode_plot_$((i-1)*nout+j)}\n"
		s*="\\end{center}\n"
		s*="\\end{figure}\n\n"
	end
end
s*="\\clearpage\n\n"

s

end  ## Leave
