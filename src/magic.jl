function tire(Fz, α, γ)


# magic tire lateral force and aligning moment
# coefficients and model from Vehicle Dynamics of Modern Passenger Cars, editor Peter Lugner, chapter Tire Characteristics and Modeling author I. J. M. Besselink
# note that Besselink uses an `adapted' ISO coordinate system, i.e., same as ISO but slip angle is positive to the right and camber is positive clockwise rotation viewed from the rear

Fz0 = 5000 # reference load

pCy1 = 1.2640
pDy1 = 0.9894
pDy2 = -0.1914
pDy3 = 0
pEy1 = -1.3186
pEy2 = -0.7057
pEy3 = 0.3278
pEy4 = -3.5829
pEy5 = 25.1493
pKy1 = 13.2701
pKy2 = 1.4990
pKy3 = 0
pKy4 = 2
pKy5 = 0
pKy6 = 0.7033
pKy7 = 0
pHy1 = -0.0019
pHy2 = 0
pVy1 = 0.0320
pVy2 = 0
pVy3 = 0.1853
pVy4 = 0.4649

r0 = 0.315 #m
qBz1 = 8.6117
qBz2 = −0.8357
qBz3 = −4.2173
qBz4 = −0.2891
qBz5 = 0.6218
qCz1 = 1.1423
qDz1 = 0.1231
qDz2 = 0.0071
qDz3 = 0
qDz4 = 9.6467
qEz1 = −3.1431
qEz2 = 0.7236
qEz3 = −6.4258
qEz4 = −0.3275
qEz5 = 0
qHz1 = −0.0067
qHz2 = 0
qHz3 = 0.1209
qHz4 = 0
qBz9 = 0
qBz10 = 0.2865
qDz6 = −0.0037
qDz7 = 0.0068
qDz8 = 0.0610
qDz9 = −0.0625
qDz10 = 0
qDz11 = 0

##

dFz = (Fz .− Fz0) ./ Fz0

Cy = pCy1

μy = (pDy1 .+ pDy2 * dFz) .* (1 .− pDy3 * γ.^2)

Dy = μy .* Fz

Kyα = pKy1 * Fz0 .* sin.(pKy4 * atan.(Fz ./ ((pKy2 .+ pKy5 * γ.^2) * Fz0))) .* (1 .− pKy3 * abs.(γ))

Kyγ = Fz .* (pKy6 .+ pKy7 * dFz)

By = Kyα ./ (Cy * Dy)

SVy0 = Fz .* (pVy1 .+ pVy2 * dFz)

SVyγ = Fz .* (pVy3 .+ pVy4 * dFz) .* γ

SVy = SVy0 + SVyγ

SHy0 = pHy1 .+ pHy2 * dFz

SHyγ = (Kyγ .* γ − SVyγ) ./ Kyα

SHy = SHy0 + SHyγ

αy = α + SHy

Ey = (pEy1 .+ pEy2 * dFz) .* (1 .+ pEy5 * γ.^2 − (pEy3 .+ pEy4 * γ) .* sign.(αy))

Fy = Dy .* sin.(Cy * atan.((1 .− Ey) .* By .* αy + Ey .* atan.(By .* αy))) + SVy

##

Ctp = qCz1

Btp = (qBz1 .+ qBz2 * dFz + qBz3 * dFz.^2) .* (1 .+ qBz4 * γ + qBz5 * abs.(γ))

Dtp = (Fz * r0/Fz0) .* (qDz1 .+ qDz2 * dFz) .* (1 .+ qDz3 * γ + qDz4 * γ.^2)

SHtp = qHz1 .+ qHz2 * dFz + (qHz3 .+ qHz4 * dFz) .* γ

αtp = α + SHtp

Etp = (qEz1 .+ qEz2 * dFz + qEz3 * dFz.^2) .* (1 .+ (qEz4 .+ qEz5 * γ) * (2/π) .* atan.(Btp .* (Ctp * αtp)))

tp = Dtp .* cos.(Ctp * atan.((1 .− Etp) .* Btp .* αtp + Etp .* atan.(Btp .* αtp))) .* cos.(α)

αr = α + SHy + SVy ./ Kyα

Br = qBz9 .+ qBz10 .* By * Cy

Dr = Fz * r0 .* ((qDz6 .+ qDz7 * dFz) + (qDz8 .+ qDz9 * dFz) .* γ) + (qDz10 .+ qDz11 * dFz) .* γ .* abs.(γ)

Mzr = Dr .* cos.(atan.(Br .* αr)) .* cos.(α)

Mz = -Fy .* tp + Mzr # should actually update Fy with γ=0 but meh

Fy, Mz

end
