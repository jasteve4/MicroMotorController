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
/*
 *-------------------------------------------------------------
 *
 * async_reg
 *
 *
 *-------------------------------------------------------------
 */


module clock_mux(
  input wire core_clock,
  input wire io_clock,
  input wire la_oenb,
  output wire  clock_out_a,
  output wire  clock_out_b,
  output wire  clock_out_c
);

  reg sel_reg;
  always@(posedge core_clock)
    sel_reg <= la_oenb;
  assign clock_out_a = (~sel_reg) ? core_clock : io_clock ;
  assign clock_out_b = clock_out_a;
  assign clock_out_c = clock_out_a;

endmodule
