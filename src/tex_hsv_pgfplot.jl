function tex_hsv_pgfplot()
## Copyright (C) 2017, Bruce Minaker
## tex_hsvd_pgfplot.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## tex_hsvd_pgfplot.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Write the tex necessary to include the plots
s="\\section{Hankel Singular Values}\n"
s*="\\begin{figure}[htbp]\n"
s*="\\begin{center}\n"
s*="\\begin{tikzpicture}\n"
s*="\\begin{axis}[height=3in,width=5in,restrict y to domain=0:100000,xlabel={Speed [m/s]},"
s*="ylabel={Hankel Singular Value []},tick style={thin,black},extra y ticks={0},extra y tick style={grid=major},"
s*="major y grid style={dotted,black},enlarge x limits=false,legend style={at={(1.0,1.03)},anchor=south east},legend columns=-1]\n"
s*="\\addplot+[black,only marks,mark=*,mark options={scale=0.6}] table[x=speed,y=hsv]{hsv.out};\n"
s*="\\end{axis}\n"
s*="\\end{tikzpicture}\n"
s*="\\caption[Hankel singular values vs speed]{Hankel singular values vs speed.}\n"
s*="\\label{hsvd_plot}\n"
s*="\\end{center}\n"
s*="\\end{figure}\n"
s*="\\clearpage\n\n"

s

end ## Leave
