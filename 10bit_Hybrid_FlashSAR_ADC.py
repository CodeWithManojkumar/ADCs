# 10 bit Hybrid Flash SAR ADC 
# Resolution increases
# 3 bit Flash ADC
# 7 bit SAR ADC
# Balance between hardware and timing
# 8 comparators are used
def flash_adc(V_in, N, V_ref):
    cmp = [0] * (2 ** N)
    cmp[0] = 1
    terminal_voltages = [i * V_ref / (2 ** N) for i in range(1, 2 ** N)]
    cmp[1:] = [int(terminal_voltages[i] <= V_in) for i in range(2 ** N - 1)]
    number = None
    for i,bit in enumerate(cmp):
        if bit == 1 :
            number = i
    binary_representation = bin(number)[2:]
    output = binary_representation.zfill(N)

    for i in range(1,2**N):
        print("Output of Comparator "+ str(2**N-i) + " is "+ str(cmp[2**N-i]))
    
    print("Output of Flash ADC in "+str(N)+ " bits : "+ str(output))

    return str(output)

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

    return ''.join(output)

def ten_bit_Hybrid_FlashSAR_ADC(V_in,V_ref):

    # Flash ADC (3-bit)
    flash_adc_output = flash_adc(V_in, 3, V_ref)

    # SAR ADC (7-bit)
    # Input can be fed to SAR ADC from the substractor (V_in and DAC output)
    # Reference can be fed from a Voltage Divider which will give Vref/8
    sar_adc_output = sar_adc(V_in - int(flash_adc_output, 2)*V_ref/2**3, 7, V_ref/2**3)

    # Combine results to get the final 10-bit output
    hybrid_adc_output = flash_adc_output + sar_adc_output

    print("Output of 10-bit Hybrid Flash-SAR ADC: " + hybrid_adc_output)
    print("Error : "+ str(V_in - int(hybrid_adc_output, 2)*V_ref/2**10))

ten_bit_Hybrid_FlashSAR_ADC(3.4,8)