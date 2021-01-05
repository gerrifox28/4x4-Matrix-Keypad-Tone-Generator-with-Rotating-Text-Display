module finalproject(clk, rows, LEDs, columns, signalout, ss1, ss2, ss3, ss4, ss5, ss6);

input [3:0] rows; //rows of keypad
input clk; //50 MHz clock
output [9:0] LEDs; //10 LEDs
output [3:0] columns; //columns of keypad
output signalout; //signalout to speaker
output [6:0] ss1, ss2, ss3, ss4, ss5, ss6; //6 seven segment displays
wire [31:0] countlow, counthigh; //countlow and counthigh for sound frequencies

keypadwithtones kwt(.rows(rows), .clk(clk), .LEDs(LEDs), .columns(columns), .countlow(countlow), .counthigh(counthigh));
rotatingdisplay rd(.clk(clk), .ss1(ss1), .ss2(ss2), .ss3(ss3), .ss4(ss4), .ss5(ss5), .ss6(ss6));
toneprocessor tp(.clk(clk), .countlow(countlow), .counthigh(counthigh), .signalout(signalout));

endmodule

module keypadwithtones(rows, clk, LEDs, columns, countlow, counthigh);

input [3:0] rows; 
input clk;
output [9:0] LEDs;
reg [9:0] LEDs;
output [3:0] columns;
reg [3:0] columns;
reg[2:0] progress, colprogress;  //progress for overall program and what column is being scanned
reg [3:0] val1, val2; //represents the inverted value of rows
reg [15:0] button1, button2; //represents the 16 bit string of the keypad output
reg [31:0] counter; //counter for switch debouncing 
output [31:0] countlow, counthigh;
reg [31:0] countlow, counthigh;

initial begin
LEDs = 10'b00_0000_0000;  //bits to output to leds 
progress = 3'b000; //progress of where in program
colprogress = 3'b000; //progress for column scanner
counter = 0; //counter for time
columns = 4'b1110; //initially start by scanning column 4
end

always @(posedge clk) begin //at positive edge of the clock 
case(progress) 

3'b000: begin //read value of button first time

case(columns) //scan columns
4'b1110: begin 
val1 = ~rows; //scan column 4
button1 = val1;
columns = 4'b1101; //set to scan column 3
end
4'b1101: begin
val1 = ~rows; //scan column 3
button1 = button1 << 4; //shift over column 4 values by 4
button1 = button1 + val1; //add column 3 value
columns = 4'b1011; //set to scan column 2
end
4'b1011: begin 
val1 = ~rows; //scan column 2
button1 = button1 << 4; //shift over column 4 and 3 values by 4
button1 = button1 + val1; //add column 2 
columns = 4'b0111; //set to scan column 1
end
4'b0111: begin
val1 = ~rows; //scan column 1
button1 = button1 << 4; //shift over column 4, 3 and 2 values by 4
button1 = button1 + val1; //add column 1
columns = 4'b1110; //reset columns back to scan column 4 for next time
progress = 3'b001; //move to next case
end
endcase
end

3'b001: begin  //wait 10 ms then scan button for second time
counter = counter + 1'b1;
if (counter >= 500000) begin  //wait 10 ms
case(columns) //start to scan button for a second time 
4'b1110: begin
val2 = ~rows;
button2 = val2;
columns = 4'b1101;
end
4'b1101: begin
val2 = ~rows;
button2 = button2 << 4;
button2 = button2 + val2;
columns = 4'b1011;
end
4'b1011: begin
val2 = ~rows;
button2 = button2 << 4;
button2 = button2 + val2;
columns = 4'b0111;
end
4'b0111: begin
val2 = ~rows;
button2 = button2 << 4;
button2 = button2 + val2;
columns = 4'b1110;
counter = 0;
progress = 3'b010;
end
endcase
end
end

3'b010: begin  //see if button has been pushed
if ((button1 == button2) && (button1 != 16'h0000)) begin //if button has been pushed
case(button1) //figure out which button has been pushed then update LEDs and countlow and counthigh accordingly
	16'h80: begin //0
	//do nothing to LED
	//no sound
	countlow = 1136;
   counthigh = 2272;
	end
	
	16'h1: begin //1
	LEDs = LEDs + 1'b1;
	//C5, 523.25 Hz roughly
	countlow = 47755;
	counthigh = 95510;
	end
		  
	16'h10: begin //2
	LEDs = LEDs + 2'b10;
	//D5, 587.33 Hz roughly
		countlow = 42565;
		counthigh = 85131;
	end
		  
	16'h100: begin //3
	LEDs = LEDs + 2'b11;
	//E5, 659.26 Hz roughly
		countlow = 37921;
		counthigh = 75842;
	end
		  
	16'h2: begin //4
	LEDs = LEDs + 3'b100;
	//F5, 698.46 Hz roughly
	countlow = 35803;
   counthigh = 71606;
	end
		  
	16'h20: begin //5
	LEDs = LEDs + 3'b101;
	//G5, 783.99 Hz roughly
		countlow = 31888;
		counthigh = 63776;
	end
	
	16'h200: begin //6
	LEDs = LEDs + 3'b110;
	//A5, 880.00 Hz roughly
		countlow = 28409;
		counthigh = 56818;
	end
	
	16'h4: begin //7
	LEDs = LEDs + 3'b111;
	//B5, 987.77 Hz roughly
		countlow = 25390;
		counthigh = 50619;
	end
	
	16'h40: begin //8
	LEDs = LEDs + 4'b1000;
	//C6, 1046.5 Hz roughly
		countlow = 23889;
		counthigh = 47778;
	end
	
	16'h400: begin //9
	LEDs = LEDs + 4'b1001;
	//D6, 1174.7 Hz roughly
		countlow = 21282;
		counthigh = 42564;
	end
	
	16'h1000: begin //10(A)
	LEDs = LEDs + 4'b1010;
	//E6, 1318.5 Hz roughly
		countlow = 18960;
		counthigh = 37921;
	end
	
	16'h2000: begin //11(B)
	LEDs = LEDs + 4'b1011;
	//F6, 1396.9 Hz roughly
		countlow = 17896;
		counthigh = 35793;
	end
	
	16'h4000: begin //12(C)
	LEDs = LEDs + 4'b1100;
	//G6, 1568.0 Hz roughly
		countlow = 15943;
		counthigh = 31887;
	end
	
	16'h8000: begin //13(D)
	LEDs = LEDs + 4'b1101;
	//A6, 1760 Hz roughly
		countlow = 14204;
		counthigh = 28409;
	end
	
	16'h8: begin //14(*)
	LEDs = LEDs + 4'b1110;
	//B6, 1976 Hz rougly
		countlow = 12651;
		counthigh = 25303;
	end
	
	16'h800: begin //15(#)
	LEDs = LEDs + 4'b1111;
	//C7, 2093 Hz rougly 
		countlow = 11944;
		counthigh = 23889;
	end

	endcase
progress = 3'b011; //if button has been pushed, go to next case to wait until it is released
end else progress = 3'b000; //if button has not been pushed, go back to beginning
end

3'b011: begin
counter = counter + 1'b1;
if (counter >= 5000000) begin //wait another 10 ms before reading again

case(columns) //read button again 
4'b1110: begin
val2 = ~rows;
button2 = val2;
columns = 4'b1101;
end
4'b1101: begin
val2 = ~rows;
button2 = button2 << 4;
button2 = button2 + val2;
columns = 4'b1011;
end
4'b1011: begin
val2 = ~rows;
button2 = button2 << 4;
button2 = button2 + val2;
columns = 4'b0111;
end
4'b0111: begin
val2 = ~rows;
button2 = button2 << 4;
button2 = button2 + val2;
columns = 4'b1110;
counter = 0;
progress = 3'b100;
end
endcase
end
end

3'b100: begin
if (button2 == 16'h0000) begin //if button now is 0 (not pushed)
progress = 3'b000; //go back to beginning
countlow = 1136; //stop playing a tone 
counthigh = 2272;
end else progress = 3'b011; //if button has not been released, go back to previous step to reread value
end

endcase 
end


endmodule 

module toneprocessor(clk, countlow, counthigh, signalout);

output signalout;
reg signalout;
input clk;
input [31:0] countlow, counthigh;
reg [31:0] onesecond, mycounter;
reg [3:0] progress;

initial begin
signalout=0; //initialize signalout to 0
onesecond = 100000000; //represents 1 second
mycounter = 0; //counter for which region
progress = 4'b0000; //progress of which region we are in
end

always@(posedge clk) begin
case(progress)

default: begin              
			end

4'b0000: begin
// Region 1
	mycounter = mycounter + 1'b1; //increase counter for region by 1
	if (mycounter < countlow) begin //if counter is less than countlow
	signalout = 0; //set signal to 0
	end
	else begin
	progress = 4'b0001; //set progress to region 2
	end
end

4'b0001: begin
//Region 2
	mycounter = mycounter + 1'b1; //increase counter for region by 1
	//if counter is equal to or greater than countlow and less than counthigh
	if ((mycounter >= countlow) && (mycounter < counthigh)) begin 
	signalout = 1; //set signal to 1
	end
	else begin
	progress = 4'b0010; //set progress to region 3
	end
end

4'b0010: begin
//Region 3
	mycounter = mycounter + 1'b1; //increase counter for region by 1
	if (mycounter >= counthigh) begin //if counter is greater than or equal to counthigh
	signalout = 0; //set signal to 0
	mycounter = 0; //restart counter
	end
	else begin
	progress = 4'b0000; //set progress to region 1
	end

end

endcase
end
endmodule 

module rotatingdisplay(clk, ss1, ss2, ss3, ss4, ss5, ss6);

input clk; //50 MHz clock
output reg [6:0] ss1, ss2, ss3, ss4, ss5, ss6; //6 seven segment displays 
reg [31:0] counter; //counter for time
reg [6:0] g,e,r1,r2,i,f1,o,x,f2,a,l1,l2,two1,zero1,two2,zero2,start; //represent bit values for each letter

initial begin
//initially set all seven segment displays to blank
ss1 = 7'hFF;
ss2 = 7'hFF;
ss3 = 7'hFF;
ss4 = 7'hFF;
ss5 = 7'hFF;
ss6 = 7'hFF;
//represents the bit strings for all needed letters 
g = 7'b0010000;
e = 7'b0000110;
r1 = 7'b1001110;
r2 = 7'b1001110;
i = 7'b1111001;
f1 = 7'b0001110;
o = 7'b1000000;
x = 7'b0001001;
f2 = 7'b0001110;
a = 7'b0001000;
l1 = 7'b1000111;
l2 = 7'b1000111;
two1 = 7'b0100100;
zero1 = 7'b1000000;
two2 = 7'b0100100;
zero2 = 7'b1000000;
end

always @(posedge clk) begin //at positive edge of clock 
counter = counter + 1'b1;
if (counter >= 50000000) begin //wait 1 second
counter = 0; //reset counter 

//move each previous seven segment display bit string up by one spot 
//initially all empty
ss6 = ss5;
ss5 = ss4;
ss4 = ss3;
ss3 = ss2;
ss2 = ss1;
ss1 = g; //sets first seven segment display 

//resets each letter in a circular pattern 
start = g;
g = e;
e = r1;
r1 = r2;
r2 = i;
i = f1;
f1 = o;
o = x;
x = f2;
f2 = a;
a = l1;
l1 = l2;
l2 = two1;
two1 = zero1;
zero1 = two2;
two2 = zero2;
zero2 = start;

end
end

endmodule

