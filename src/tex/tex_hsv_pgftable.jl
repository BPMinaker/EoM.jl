function tex_hsv_pgftable()
## Copyright (C) 2017 Bruce Minaker
## tex_hsv_table.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## tex_hsv_table.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

s="\\section{Hankel Singular Value Analysis}\n"
s*="The Hankel singular values are given in Table~\\ref{svals}.\n\n"

s*="\\begin{table}[ht]\n"
s*="\\begin{center}\n"
s*="\\begin{footnotesize}\n"
s*="\\caption{Hankel Singular Values}\n"
s*="\\label{svals}\n"
s*="\\pgfplotstabletypeset[columns={num,hsv}]{hsv.out}\n"
s*="\\end{footnotesize}\n"
s*="\\end{center}\n"
s*="\\end{table}\n"

s

end ## Leave
