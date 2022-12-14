// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
//`include "./driver.v"

`timescale 1 ns / 1 ps

module system_test_tb;

  localparam NUM_OF_DRIVERS =10;
  localparam NUM_OF_ROWS =5;
  localparam NUM_OF_COLS =5;
  localparam CCR0 =32;
  localparam CCR1 =128;
  localparam DRIVER_MEM_LEN = 48;
  localparam NUM_OF_UPDATE_CYCLES = NUM_OF_ROWS*NUM_OF_COLS;  
  localparam MEM_LENGTH           =48;
  localparam MEM_ADDRESS_LENGTH   =6;
  localparam MEM_BOUND            =3;
  localparam NUM_OF_DOTS_PER_MEM    = 3;
  localparam ACTIVE_MEM_LOWER_BOUND = 0;
  localparam ACTIVE_MEM_UPPER_BOUND = ACTIVE_MEM_LOWER_BOUND + NUM_OF_DOTS_PER_MEM * MEM_LENGTH - 1 ;
  localparam SELECT_MEM_LOWER_BOUND = ACTIVE_MEM_UPPER_BOUND + 1 ;
  localparam SELECT_MEM_UPPER_BOUND = SELECT_MEM_LOWER_BOUND + MEM_LENGTH -1 ;
  localparam DOT_MEM_LOWER_BOUND    = SELECT_MEM_UPPER_BOUND + 1 ;
  localparam DOT_MEM_UPPER_BOUND    = DOT_MEM_LOWER_BOUND + NUM_OF_DOTS_PER_MEM - 1 ;
  localparam SYS_MEM_BOUND          = DOT_MEM_UPPER_BOUND;
  localparam SYS_MEM_ADDRESS_LENGTH = 2*MEM_ADDRESS_LENGTH;
  integer seed=0;
	



	reg 		clock;
	reg 		spi_clock;
    	reg 		RSTB;
	reg 		CSB;

	reg 		power1, power2;

	wire 		gpio;
	wire [37:0] 	mprj_io;


  // Chip IO
  	reg           reset_n;
  	reg           latch_data;
  	reg           control_trigger;
  	wire           sclk;
	reg           mosi;
	reg           ss_n;
	wire          miso;
	wire [NUM_OF_DRIVERS*2-1:0]   driver_io;
	wire          update_cycle_complete;

	wire  		output_state [0:NUM_OF_ROWS-1][NUM_OF_COLS-1:0];
	reg 		dot_2d_array [0:NUM_OF_ROWS-1][NUM_OF_COLS-1:0];
	wire [NUM_OF_DRIVERS*2-1:0]   driver_cell_output;
	wire [NUM_OF_ROWS*NUM_OF_COLS-1:0]   output_state_1d;
	reg [NUM_OF_ROWS*NUM_OF_COLS-1:0]   ref_state_1d;


	assign mprj_io[37]   =	reset_n;     	
	assign mprj_io[36]   =	control_trigger; 	  
	assign mprj_io[35]   = 	latch_data;	
	assign miso          = 	mprj_io[34];
	assign mprj_io[33]   =  mosi; 	   	
	assign mprj_io[32]   = 	ss_n; 	   	
	assign mprj_io[31]   = 	sclk; 	   	
	assign update_cycle_complete = mprj_io[30];
	assign driver_io[0]  = 	mprj_io[29];
	assign driver_io[1]  = 	mprj_io[28];
	assign driver_io[2]  = 	mprj_io[27];
	assign driver_io[3]  = 	mprj_io[26];
	assign driver_io[4]  = 	mprj_io[25];
	assign driver_io[5]  = 	mprj_io[24];
	assign driver_io[6]  = 	mprj_io[23];
	assign driver_io[7]  = 	mprj_io[22];
	assign driver_io[8]  = 	mprj_io[21]; 	   	
	assign driver_io[9]  = 	mprj_io[20]; 	   	
	assign mprj_io[19]   = 	0; 	   	
	assign driver_io[10] =  mprj_io[18]; 	   	
	assign driver_io[11] = 	mprj_io[17]; 	   	
	assign driver_io[12] = 	mprj_io[16]; 	   	
	assign driver_io[13] = 	mprj_io[15];
	assign driver_io[14] = 	mprj_io[14];
	assign driver_io[15] = 	mprj_io[13];
	assign driver_io[16] = 	mprj_io[12];
	assign driver_io[17] = 	mprj_io[11];
	assign driver_io[18] = 	mprj_io[10]; 
	assign driver_io[19] = 	mprj_io[9]; 
	assign mprj_io[8] = 	clock;
	assign mprj_io[7]   = 	0; 	   	
	assign mprj_io[6]   = 	0; 	   	
	assign mprj_io[5]   = 	0; 	   	
	assign mprj_io[4]   = 	0; 	   	
	assign mprj_io[3]   = 	0; 	   	
	assign mprj_io[2]   = 	0; 	   	
	assign mprj_io[1]   = 	0; 	   	
	assign mprj_io[0]   = 	0; 	   	


	pulldown (weak0,strong1) p (gpio);

	//always #12.5 clock <= (clock === 1'b0);
	always #40 clock <= (clock === 1'b0);
	//always #100 spi_clock <= (spi_clock === 1'b0);
	always #150 spi_clock <= (spi_clock === 1'b0);
  	assign sclk = ~ss_n & spi_clock;


	

	initial begin
		clock 		= 0;
      		spi_clock     	= 1;
	end

	// Set the init state of input pins to asic
	task init_signals;
      	begin
        	reset_n 	= 0;
        	control_trigger	= 0;
        	latch_data	= 0;
        	mosi 		= 0;
        	ss_n		= 1;
		wait_n_clocks(50);
    	end
  	endtask
	// set the enable signal to chip
	task enable_chip;
	begin
	      	reset_n      = 1; 
	end
	endtask

	// unset the enable signal to chip
	task disable_chip;
	begin
	      	reset_n      = 0; 
	end
	endtask
	
	// pass time 
  	task wait_n_clocks;
    	input integer i;
    	integer j;
    	begin
      		for(j=0;j<i;j=j+1)
        	@(posedge clock);
    	end
  	endtask

	task spi_shift;
	input [31:0] data_in;
	output [31:0] data_out;
	integer ii;
	begin
		for(ii=0;ii<32;ii=ii+1)
		begin
			@(negedge spi_clock);
			ss_n = 1'b0;
			mosi = data_in[31];
			data_in = data_in << 1;
			@(posedge spi_clock)
			data_out = {data_out[31:0],miso};
		end
		@(negedge spi_clock);
		ss_n = 1'b1;
		@(posedge clock);
		@(posedge clock);
	end
	endtask

	task spi_write;
	input [31:0] spi_data;
	reg   [31:0] pass;
	begin
		wait_n_clocks(50); 
		latch_data=0;
		wait_n_clocks(50); 
		spi_shift(spi_data,pass);
		wait_n_clocks(50); 
		latch_data=1;
		wait_n_clocks(100); 
		latch_data=0;
		wait_n_clocks(50); 
	end
	endtask

  task write_mem_data_cmd;
    input [3:0]  driver_select;
    input [9:0]  address;
    input [15:0] data;
    reg [31:0] cmd; 
    begin
      cmd[15:0] = data;
      cmd[25:16] = address;
      cmd[29:26] = driver_select;
      cmd[31:30] = 2'b00;
      wait_n_clocks(10);
      wait_n_clocks(10);
      spi_write(cmd);
      wait_n_clocks(10);
    end
  endtask


  task clear_mem;
    input [3:0] device_select;
    integer ii;
    begin
      for(ii=0;ii<SYS_MEM_BOUND+1;ii=ii+1) begin
        write_mem_data_cmd(device_select,ii,16'b0);
      end
    end
  endtask


  task write_to_select_mem;
    input [3:0]  driver_select;
    input [31:0] idx;
    input [31:0] data;
    begin
      write_mem_data_cmd(driver_select,idx+SELECT_MEM_LOWER_BOUND,data); 
    end
  endtask

  task write_to_active_mem;
    input [3:0]  driver_select;
    input [31:0] idx;
    input [31:0] data;
    begin
      write_mem_data_cmd(driver_select,idx+ACTIVE_MEM_LOWER_BOUND,data); 
    end
  endtask

  task write_to_dot_data_mem;
    input [3:0]  driver_select;
    input [31:0] idx;
    input [31:0] data;
    begin
      write_mem_data_cmd(driver_select,idx+DOT_MEM_LOWER_BOUND,data); 
    end
  endtask



  task oneshot_exe;
    begin
      @(posedge clock);
      spi_write({2'b11,4'b1101,26'b0});
      wait_n_clocks(100);
      control_trigger = 1'b1;
      wait_n_clocks(100);
      control_trigger = 1'b0;
      @(posedge update_cycle_complete);
      wait_n_clocks(10);
    end
  endtask

  task refresh_display;
  begin
      control_trigger = 1'b1;
      wait_n_clocks(100);
      control_trigger = 1'b0;
      @(posedge update_cycle_complete);
  end
  endtask

  task update_select;
    input [31:0] driver_select;
    integer ii;
    begin
      for(ii=0;ii<48;ii=ii+1)
      begin
        write_to_select_mem(driver_select,ii,ii);
      end
    end
  endtask

  task update_active_mem_row;
    input [3:0]   driver_select;
    input [6:0]   address;
    input [47:0] data;
    integer ii;
    reg [15:0] d;
    begin
      for(ii=0;ii<3;ii=ii+1)
      begin
        @(posedge clock);
        d = data>>(16*ii);
        @(posedge clock);
        write_to_active_mem(driver_select,address*3,d);
        @(posedge clock);
      end
    end
  endtask

  task update_active_mem_col;
    input [3:0]   driver_select;
    input [9:0]   address;
    input [47:0] data;
    integer ii;
    reg d; 
    reg [15:0] insert_data;
    reg [2:0] mask_offset ;
    reg [9:0] address_offset;
    reg [9:0] row_address;
    begin
      for(ii=0;ii<48;ii=ii+1)
      begin
        insert_data = data[ii];
        @(posedge clock);
        if(address < 16) begin
          address_offset = 0;
          insert_data = insert_data << address;
        end else if(address < 32) begin
          address_offset = 1;
          insert_data = insert_data << (address - 16);
        end else begin
          address_offset = 2;
          insert_data = insert_data << (address - 32);
        end
        row_address = address_offset+3*ii;
        @(posedge clock);
        write_to_active_mem(driver_select,row_address,insert_data);
        @(posedge clock);
      end
    end
  endtask

  task update_dot_data;
    input [3:0]   driver_select;
    input [47:0] data;
    integer ii;
    reg [15:0] d;
    begin
      for(ii=0;ii<3;ii=ii+1)
      begin
        @(posedge clock);
        d = data>>(16*ii);
        @(posedge clock);
        write_to_dot_data_mem(driver_select,ii,d);
        @(posedge clock);
      end
    end
  endtask

  task write_config_cmd;
    input [9:0]  address;
    input [15:0] data;
    reg [31:0] cmd; 
    begin
      cmd[15:0] = data;
      cmd[25:16] = address;
      cmd[29:26] = 4'b0;
      cmd[31:30] = 2'b10;
      wait_n_clocks(10);
      wait_n_clocks(10);
      spi_write(cmd);
      wait_n_clocks(10);
    end
  endtask


  task config_backend;
    input [31:0] _ccr0;
    input [31:0] _ccr1;
    input [31:0] _ordering_complete;
    input [31:0] _row_limit;
    input [31:0] _col_limit;
    input [31:0] _inverter_select;
    input [31:0] _row_col_select;
    begin
      @(posedge clock);
      write_config_cmd(0,_ccr0[15:0]);
      write_config_cmd(1,_ccr0[31:16]);
      write_config_cmd(2,_ccr1[15:0]);
      write_config_cmd(3,_ccr1[31:16]);
      write_config_cmd(4,_ordering_complete[15:0]);
      write_config_cmd(5,_ordering_complete[31:16]);
      write_config_cmd(6,_row_limit);
      write_config_cmd(7,_col_limit);
      write_config_cmd(8,_inverter_select);
      write_config_cmd(9,_row_col_select);
    end
  endtask

  task set_config_5x5;
    integer ii, jj;
    reg [31:0] device;
    begin
      config_backend(CCR0,CCR1,NUM_OF_UPDATE_CYCLES,NUM_OF_ROWS-1,NUM_OF_COLS-1,16'b0000_0011_1110_0000,16'b0000_0000_0001_1111);
      for(ii=0;ii<NUM_OF_ROWS;ii=ii+1)
      begin
        device = ii;
        update_active_mem_row(device,device,~(48'b0));
        update_select(device);
      end
      for(ii=0;ii<NUM_OF_COLS;ii=ii+1)
      begin
        device = ii;
        update_active_mem_col(device+NUM_OF_ROWS,device,~(48'b0));
        update_select(device+NUM_OF_ROWS);
      end
    end
  endtask

  task write_5x5_data;
    //reg data [0:NUM_OF_ROWS-1][NUM_OF_COLS-1:0];
    integer ii,jj;
    reg [47:0] row;
    reg [47:0] col;
    begin
      //data=dot_2d_array;
      row=0;
      col=0;
      for(jj=0;jj<NUM_OF_ROWS;jj=jj+1)
      begin
        for(ii=0;ii<NUM_OF_COLS;ii=ii+1)
        begin
          row[ii] = dot_2d_array[jj][ii];
	  ref_state_1d[jj*NUM_OF_COLS+ii] = dot_2d_array[jj][ii];
          @(posedge clock);
        end
        update_dot_data(jj,row);
      end
      for(jj=0;jj<NUM_OF_COLS;jj=jj+1)
      begin
        for(ii=0;ii<NUM_OF_ROWS;ii=ii+1)
        begin
          col[ii] = dot_2d_array[ii][jj];
          @(posedge clock);
        end
        update_dot_data(jj+NUM_OF_ROWS,col);
      end
    end
  endtask

	task check_output;
	input [31:0] test_case;
	integer ii,jj;
	reg pass;
	begin
		pass=1;
		for(ii=0;ii<NUM_OF_ROWS;ii=ii+1)
		begin
			for(jj=0;jj<NUM_OF_COLS;jj=jj+1)
			begin
				@(posedge clock);
				if(dot_2d_array[ii][jj] === output_state[ii][jj])
				begin
					pass=pass&1;
				end
				else
				begin
					pass=pass&0;

				end
			end
		end
		if(pass === 0)
		begin
			$display("Test [%d] FAILED",test_case);
			for(ii=0;ii<NUM_OF_ROWS;ii=ii+1)
			begin
				for(jj=0;jj<NUM_OF_COLS;jj=jj+1)
				begin
					if(!(dot_2d_array[ii][jj] === output_state[ii][jj]))
					begin
						$display("testcase[%d] failed : orig[%d][%d]: %d != %d",test_case,ii,jj,dot_2d_array[ii][jj],output_state[ii][jj]);
					end
				end
			end
		end
		else
		begin
		  $display("Test Case [%d] Passed",test_case);
		end
	end
 	endtask

	task test_output_5x5;
	input [31:0] test_case;
	reg [NUM_OF_ROWS*NUM_OF_COLS-1:0] dot_array;
	integer ii,jj;
	begin
		ii=0;
		seed = $random(seed);
		dot_array = seed ^ ($random(seed) ^ $random(ii));
		set_config_5x5();
		for(ii=0;ii<NUM_OF_ROWS;ii=ii+1)
		begin
			for(jj=0;jj<NUM_OF_COLS;jj=jj+1)
			begin
				dot_2d_array[ii][jj] = dot_array[ii*NUM_OF_COLS+jj];
			end
		end
		$display("writing 2d array to asic");
		write_5x5_data();
		$display("staring onshot execute asic");
		oneshot_exe();
		check_output(test_case);
	end
	endtask


	initial
	begin
                init_signals();
		#200;
		@(posedge gpio);
		$display("staring test");
		wait_n_clocks(10);
		disable_chip();
		wait_n_clocks(100);
		enable_chip();
		wait_n_clocks(100);
		test_output_5x5(0);
		test_output_5x5(1);
		wait_n_clocks(100);
		$finish();
	  

	end

	initial begin
		$dumpfile("system_test.vcd");
		$dumpvars(1, system_test_tb);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (400) @(posedge clock);
		@(posedge gpio)
		repeat (10000) begin
			repeat (100) @(posedge clock);
			//$display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		`ifdef GL
			$display ("Monitor: Timeout, Test LA (GL) Failed");
		`else
			$display ("Monitor: Timeout, Test LA (RTL) Failed");
		`endif
		$display("%c[0m",27);
		$finish;
	end
	
	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#2000;
		RSTB <= 1'b1;	    	// Release reset
		#170000;
		CSB = 1'b0;		// CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		#200;
		power1 <= 1'b1;
		#200;
		power2 <= 1'b1;
	end

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD1V8;
	wire VDD3V3;
	wire VSS;
    
	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	//assign mprj_io[3] = 1;  // Force CSB high.
	//assign mprj_io[0] = 0;  // Disable debug mode

	caravel uut (
		.vddio	  (VDD3V3),
		.vddio_2  (VDD3V3),
		.vssio	  (VSS),
		.vssio_2  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda1_2  (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa1_2  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock    (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("system_test.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

	genvar I,J;
	generate
		for(I=0;I<NUM_OF_DRIVERS;I=I+1)
		begin
			HBCell u5(
				.p_in                 (driver_io[I*2+1]),
				.n_in                 (driver_io[I*2]),
				.line                 (driver_cell_output[I])
			);
		end                       
		for(I=0;I<NUM_OF_ROWS;I=I+1)
		begin
			for(J=0;J<NUM_OF_COLS;J=J+1)
			begin
				cell_converter u7(
					.in                 ({driver_cell_output[I],driver_cell_output[J+NUM_OF_ROWS]}),
					.state              (output_state[I][J])
				);
				assign output_state_1d[I*NUM_OF_COLS+J] = output_state[I][J];
			end
		end
	endgenerate                 
		`ifdef ENABLE_SDF
	        
		initial begin
			//$sdf_annotate("../../../sdf/user_project_wrapper.sdf", uut.mprj) ;
			//$sdf_annotate("../../../sdf/controller_unit.sdf", uut.mprj.controller_unit_mod) ;
			//$sdf_annotate("../../../sdf/driver_core.sdf", uut.mprj.driver_core_0) ;
			//$sdf_annotate("../../../sdf/driver_core.sdf", uut.mprj.driver_core_1) ;
			//$sdf_annotate("../../../sdf/driver_core.sdf", uut.mprj.driver_core_2) ;
			//$sdf_annotate("../../../sdf/driver_core.sdf", uut.mprj.driver_core_3) ;
			//$sdf_annotate("../../../sdf/driver_core.sdf", uut.mprj.driver_core_4) ;
			//$sdf_annotate("../../../sdf/driver_core.sdf", uut.mprj.driver_core_5) ;
			//$sdf_annotate("../../../sdf/driver_core.sdf", uut.mprj.driver_core_6) ;
			//$sdf_annotate("../../../sdf/driver_core.sdf", uut.mprj.driver_core_7) ;
			//$sdf_annotate("../../../sdf/driver_core.sdf", uut.mprj.driver_core_8) ;
			//$sdf_annotate("../../../sdf/driver_core.sdf", uut.mprj.driver_core_9) ;
			//$sdf_annotate("../../../mgmt_core_wrapper/sdf/DFFRAM.sdf", uut.soc.DFFRAM_0) ;
			/*
			$sdf_annotate("../../../mgmt_core_wrapper/sdf/DFFRAM.sdf", uut.soc.DFFRAM_0) ;
			$sdf_annotate("../../../mgmt_core_wrapper/sdf/mgmt_core.sdf", uut.soc.core) ;
			$sdf_annotate("../../../caravel/sdf/housekeeping.sdf", uut.housekeeping) ;
			$sdf_annotate("../../../caravel/sdf/chip_io.sdf", uut.padframe) ;
			$sdf_annotate("../../../caravel/sdf/mprj_logic_high.sdf", uut.mgmt_buffers.mprj_logic_high_inst) ;
			$sdf_annotate("../../../caravel/sdf/mprj2_logic_high.sdf", uut.mgmt_buffers.mprj2_logic_high_inst) ;
			$sdf_annotate("../../../caravel/sdf/mgmt_protect_hv.sdf", uut.mgmt_buffers.powergood_check) ;
			$sdf_annotate("../../../caravel/sdf/mgmt_protect.sdf", uut.mgmt_buffers) ;
			$sdf_annotate("../../../caravel/sdf/caravel_clocking.sdf", uut.clocking) ;
			$sdf_annotate("../../../caravel/sdf/digital_pll.sdf", uut.pll) ;
			$sdf_annotate("../../../caravel/sdf/xres_buf.sdf", uut.rstb_level) ;
			$sdf_annotate("../../../caravel/sdf/user_id_programming.sdf", uut.user_id_value) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_bidir_1[0] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_bidir_1[1] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_bidir_2[0] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_bidir_2[1] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_bidir_2[2] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[0] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[1] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[2] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[3] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[4] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[5] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[6] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[7] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[8] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[9] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1[10] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1a[0] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1a[1] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1a[2] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1a[3] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1a[4] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_1a[5] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[0] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[1] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[2] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[3] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[4] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[5] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[6] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[7] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[8] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[9] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[10] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[11] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[12] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[13] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[14] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_control_block.sdf", uut.\gpio_control_in_2[15] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.\gpio_defaults_block_0[0] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.\gpio_defaults_block_0[1] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.\gpio_defaults_block_2[0] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.\gpio_defaults_block_2[1] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.\gpio_defaults_block_2[2] ) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_5) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_6) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_7) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_8) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_9) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_10) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_11) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_12) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_13) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_14) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_15) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_16) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_17) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_18) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_19) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_20) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_21) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_22) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_23) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_24) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_25) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_26) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_27) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_28) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_29) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_30) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_31) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_32) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_33) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_34) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_35) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_36) ;
			$sdf_annotate("../../../caravel/sdf/gpio_defaults_block.sdf", uut.gpio_defaults_block_37) ;
			*/
		end
	`endif
endmodule


`ifdef ENABLE_SDF
`celldefine
module sky130_ef_sc_hd__decap_12 (
    VPWR,
    VGND,
    VPB ,
    VNB
);

    // Module ports
    input VPWR;
    input VGND;
    input VPB ;
    input VNB ;
     // No contents.
endmodule
`endcelldefine
`endif
module HBCell(
input wire p_in,
input wire n_in,
output wire line
);

wire common;
wire temp1;
wire temp2;

nmos n1Mos (common,1'b0,n_in);
pmos p1Mos (common,1'b1,p_in);

assign line = common;

endmodule

module cell_converter(
input wire [1:0] in,
output reg state
);

always@(*)
begin
state = state;
if((in[0] == 1) & (in[1] == 0))
begin
state = 1'b0;
end
if((in[1] == 1) & (in[0] == 0))
begin
state = 1'b1;
end
end

initial
begin
state = 1'bz;
end

endmodule
