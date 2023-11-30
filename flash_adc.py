# fastest ADC
# consists of Comparator, Voltage Divider Circuit and Priority Encoder
# 2^N -1 comparators
# 2^N matched resistors

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

flash_adc(3.3,3,8)

