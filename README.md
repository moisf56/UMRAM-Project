# UMRAM-Project
# Gradient Descent Algorithm for MRI Image Reconstruction 
Assembly 8051
Image reconstruction is a procedure that gets applied on the sensor data (signals) picked up by the RF receiver coil pf the MRI machine to get an actual image. Normally, an inverse Fourier transform is applied on the signals. However,  we need at least n frequencies to reconstruct an image with n pixels, and the problem with that is the time factor;  since the MRI scan is scaled linearly with the number of frequencies obtained - which has a typical value of 10 million frequencies, - the MRI scan can often take up to an hour. To solve this, we take advantage of the fact that MRI images don't possess many edges, and incorporate this with the collected measurements by attempting to solve the following optimization problem
arg_x_min ∣∣ [M ⊙ F(x)] - y ∣∣_2 + R_TV (x) ; 
where R_TV(x) = ∣∣ ∇x ∣∣1 : ( ||.||_1) is the L1 norm and (∇) is the spatial gradient 
( ||.||_2) is the L2 norm ||.||_2 = ∑_i (|z_i|)^2
