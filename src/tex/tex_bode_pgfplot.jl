function tex_bode_pgfplot(ins,outs)
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

for i=1:nin  ## For each input
	s="\\begin{figure}[hbtp]\n"
	s*="\\begin{center}\n"
	s*="\\begin{footnotesize}\n"
	s*="\\begin{tikzpicture}\n"
  s*="\\begin{semilogxaxis}[height=2in,width=5in,tick style={thin,black},"
  s*="extra y ticks={0},extra y tick style={grid=major},major y grid style={dotted,black},"
  s*="xlabel={Frequency [\\si{\\hertz}]},ylabel={Transfer Function [\\si{\\decibel}]},enlarge x limits=false,"
  s*="legend style={at={(1.0,1.03)},anchor=south east},legend columns=1,legend cell align=left,cycle list name=linestyles*]\n"
	for j=1:nout  ## For each output
		s*="\\addplot+[black,line width=1pt,mark=none] table[x=frequency,y=m$((i-1)*nout+j)]{bode.out};\n"
		s*="\\addlegendentry{$(outs[j]) / $(ins[i])}\n"
	end
	s*="\\end{semilogxaxis}\n"
	s*="\\end{tikzpicture}\n"
	s*="\\begin{tikzpicture}\n"
	s*="\\begin{semilogxaxis}[height=2in,width=5in,ymin=-180,ymax=180,ytick={-180,-90,0,90,180},"
	s*="tick style={thin,black},extra y ticks={0},extra y tick style={grid=major},major y grid style={dotted,black},"
	s*="xlabel={Frequency [\\si{\\hertz}]},ylabel={Phase Angle [\\si{\\degree}]},enlargelimits=false,cycle list name=linestyles*,"
	s*="restrict y to domain= -180:180,unbounded coords=jump]\n"
	for j=1:nout
		s*="\\addplot+[black,line width=1pt,mark=none] table[x=frequency,y=p$((i-1)*nout+j)]{bode.out};\n"
	end
	s*="\\end{semilogxaxis}\n"
	s*="\\end{tikzpicture}\n"
	s*="\\end{footnotesize}\n"
	s*="\\caption{Frequency response: $(ins[i])}\n"
	s*="\\label{bode_plot_$i}\n"
	s*="\\end{center}\n"
	s*="\\end{figure}\n\n"

end
s*="\\clearpage\n\n"

s

end ## Leave
