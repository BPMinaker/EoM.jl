function tex_sstf_pgftable()
## Copyright (C) 2017, Bruce Minaker
## tex_sstf_pgfplot.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## tex_sstf_pgfplot.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

s="\\section{Steady State Gains}\n"  ## Write the tex necessary to include the plots
s*="The steady state gains are given in Table~\\ref{sstf}.\n"
s*="\\begin{table}[ht]\n"
s*="\\begin{center}\n"
s*="\\begin{footnotesize}\n"
s*="\\caption{Steady State Gains}\n"
s*="\\label{sstf}\n"
s*="\\pgfplotstabletypeset{sstf.out}\n"
s*="\\end{footnotesize}\n"
s*="\\end{center}\n"
s*="\\end{table}\n"

s

end ## Leave
