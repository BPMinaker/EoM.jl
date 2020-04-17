function random_road(;class::Int=3,L=100.,B=0.05)

# class is an integer from 3 - 9, where class=3 is an A-B road (smooth), class=9 is G-H road (rough)
# L is max wavelength [m], also equals road length
# B shortest wavelength, approx [m]

if(class<3)
	class=3
	println("Warning: class out of range, resetting to minimum value (3)")
end

if(class>9)
	class=9
	println("Warning: class out of range, resetting to maximum value (9)")
end

deltan=1/L  # spatial frequency interval
N=Int(round(L/B))  # number of frequencies

n=deltan:deltan:N*deltan  # frequency span

phi=rand(N)*2*pi  # N random phase lag, 1 for each frequency, from 0-2pi

a=sqrt(deltan)*(2^class)*1e-4./n  # amplitude of each frequency, based on psd content

# sum for each frequency included
z0=a'*cos.(phi)

z(x)=a'*cos.(n*2pi*x+phi)-z0

z

end ## Leave
