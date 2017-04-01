function tex_eig_pgftable()
## Copyright (C) 2017 Bruce Minaker
## tex_eig_table.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## tex_eig_table.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

s="\\section{Eigenvalue Analysis}\n"
s*="The eigenvalue properties are given in Tables~\\ref{evals}~and~\\ref{evals-b}.\n\n"

s*="\\begin{center}\n"
s*="\\begin{footnotesize}\n"
s*="\\pgfplotstabletypeset[%\n"
s*="begin table=\\begin{longtable},\n"
s*="end table=\\end{longtable},\n"
s*="every head row/.style={\n"
s*="before row={\\caption{Eigenvalues}\\label{evals}\\\\ \\toprule},\n"
s*="after row=\\midrule},\n"
s*="every last row/.style={\n"
s*="after row=\\bottomrule \\multicolumn{9}{l}{Note: oscillatory roots appear as complex conjugates.}},\n"
s*="columns={num,real,imag,realhz,imaghz}]{eigen.out}\n"
s*="\\end{footnotesize}\n"
s*="\\end{center}\n"

## New table

s*="\\begin{center}\n"
s*="\\begin{footnotesize}\n"
s*="\\pgfplotstabletypeset[%\n"
s*="begin table=\\begin{longtable},\n"
s*="end table=\\end{longtable},\n"
s*="every head row/.style={\n"
s*="before row={\\caption{Eigenvalue Analysis}\\label{evals-b}\\\\ \\toprule},\n"
s*="after row=\\midrule},\n"
s*="every last row/.style={\n"
s*="after row=\\bottomrule \\multicolumn{9}{l}{Notes: a) oscillatory roots are listed twice, b) negative time constants denote unstable roots.}},\n"
s*="columns={num,nfreq,zeta,tau,lambda}]{freq.out}\n"
s*="\\end{footnotesize}\n"
s*="\\end{center}\n"

s

end  ## Leave
