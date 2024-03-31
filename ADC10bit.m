% Input
vinp = 0:0.00005:1; % Inputs from 0V to 1V
v_out_array = zeros(1,size(vinp,2));
residue_array =zeros(1,size(vinp,2));
iter = 0;
vout_flash = zeros(1,size(vinp,2));
flash_residue = zeros(1,size(vinp,2));

for vinput = 0:0.00005:1
    iter = iter+1;

    refp = 1;
    refm = 0;

    vin = vinput / (refp - refm) - refm ; % Input Voltage to ADC

    % Flash ADC 3-bit
     Flash_offset = [0.01 -0.01 -0.01 0.01 -0.01 -0.01 0.01]; % LSB first
     Flash_comp_ideal = (0.125:0.125:0.875);
     Flash_comp_actual = Flash_comp_ideal+Flash_offset;
      
     thermo_code = zeros(1,7);
     j = 0;

     for i = 1:7
         if(vin > Flash_comp_actual(i))
             thermo_code(i) = 1;
             j = j + 1;
         end
     end

     vbin = decimalToBinaryVector(j,3);
     resid = vin;
     

     if (j ~= 0)
        resid = vin - Flash_comp_ideal(j);
     end
    vout_flash(iter) = j;
    flash_residue(iter)=resid;

    sar_red = zeros(1, 2); % Redundant Bits
    sar_bit = zeros(1, 7); % Output bits
    n = (0:1:9);
	Cn = [1,2.^n];
	Ctot = sum(Cn);
	Csar = flip(Cn(2:8));
	
	% SAR Conversion
	for i = 1:2
		sar_bit(i) = 1;
		Csum = sum(sar_bit.*Csar);
		sar_resid = resid - Csum/Ctot;
		if(sar_resid <= 0)
			sar_bit(i) = 0;
		end
	end
	
	% Redundant Check
	if sar_bit(2) == 1
		resid = resid - 32/Ctot; % Connect both Redundant Caps to GND
		Csum = sum(sar_bit.*Csar);
		sar_resid = resid - Csum/Ctot;
		
		if sar_resid <= 0
			sar_red(1) = 0;
			resid = resid + 32/Ctot; % Restore CDAC
		else 
			sar_red(1) = 1; % Continue
		end
	
	else
		Csum = sum(sar_bit.*Csar);
		sar_resid = resid - Csum/Ctot;
		
		if sar_resid < 0
			sar_red(1) = 0;
			resid = resid + 32/Ctot;% Substract 32 LSBS in MO
		else
			sar_red(1) = 1;
		end
	end
	
	% SAR Conversion
	for i = 3:5
		sar_bit(i) = 1;
		Csum = sum(sar_bit.*Csar);
		sar_resid = resid - Csum/Ctot;
		if(sar_resid <= 0)
			sar_bit(i) = 0;
		end
	end
	
	% Redundant Check
	if sar_bit(5) == 1
		resid = resid - 4/Ctot;
		Csum = sum(sar_bit.*Csar);
		sar_resid = resid - Csum/Ctot;
		
		if (sar_resid <= 0)
			sar_red(2) = 0;
			resid = resid + 4/Ctot;
		else 
			sar_red(2) = 1;
		end
	
	else
		Csum = sum(sar_bit.*Csar);
		sar_resid = resid - Csum/Ctot;
		
		if (sar_resid < 0)
			sar_red(2) = 0;
			resid = resid + 4/Ctot;
		else
			sar_red(2) = 1;
		end
	end
	
	% SAR Conversion
	for i = 6:7
		sar_bit(i) = 1;
		Csum = sum(sar_bit.*Csar);
		sar_resid = resid - Csum/Ctot;
		if(sar_resid <= 0)
			sar_bit(i) = 0;
		end
	end
	
			
    mo = [vbin, sar_bit];
    mo_dec = binaryVectorToDecimal(mo);
	
	if sar_bit(2) == 1 && sar_red(1) == 1
		mo_dec = mo_dec + 32;
	end
	
	if sar_bit(2) == 0 && sar_red(1) == 0
		mo_dec = mo_dec - 32;
	end
	
	if sar_bit(5) == 1 && sar_red(2) == 1
		mo_dec = mo_dec + 4;
	end
	
	if sar_bit(5) == 0 && sar_red(2) == 0
		mo_dec = mo_dec - 4;
	end

    if (mo_dec ~= 0)
        bin_out = decimalToBinaryVector(mo_dec, 10);
    else
        bin_out = zeros(1, 10);
    end

    v_bin_out = mo_dec / 1024;
    v_out = (refp - refm) * v_bin_out + refm;
    final_residue = 1024 * (vinput - v_out);

    v_out_array(iter) = mo_dec;
    residue_array(iter) = final_residue;
	
end
figure;
plot(vinp, vout_flash, "b-", "LineWidth", 1);
grid on;
hold on;
title("Output Flash Code (3-bit) vs. Input");
xlabel("Input(V)");
ylabel("Output Code(LSB)");

figure;
plot(vinp, flash_residue, "b-", "LineWidth", 1);
grid on;
hold on;
title("Flash Residue vs. Input");
xlabel("Input(V)");
ylabel("Residue");

figure
plot(vinp, residue_array, "r-", "LineWidth", 1.5);
hold on;
grid on;
title("Residue Plot");
xlabel("Input(V)");
ylabel("Residue(LSB)");

figure
plot(vinp, v_out_array, "b-", "LineWidth", 1);
grid on;
hold on;
title("Output Code vs. Input");
xlabel("Input(V)");
ylabel("Output Code(LSB)");

figure
s = inldnl(vinp, v_out_array, [0, 1], "ADC");
plot(s.Codes, s.INL, "g-", "Linewidth", 1);
grid on;
hold on;
xlim([0, 1024]);
title("INL Plot");
xlabel("Output Code (LSB)");
ylabel("INL(LSB)");

figure
plot(s.Codes, s.DNL, "b-", "Linewidth", 1);
grid on;
hold on;
xlim([0, 1024]);
title("DNL Plot");
xlabel("Output Code (LSB)");
ylabel("DNL(LSB)");