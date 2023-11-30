# Successive Approximation ADC
def sar_adc(V_in,N,V_ref):
    output = []
    V_out = 0
    for i in range(N):
        V_out += V_ref/2**(i+1)
        if(V_out > V_in):
            V_out -= V_ref/2**(i+1)
            output.append('0')
        else:
            output.append('1')
    print("Output of SAR ADC in "+str(N)+ " bits : "+ ''.join(output))
    print("Error : "+str(V_in-V_out))

sar_adc(6.74,3,10)