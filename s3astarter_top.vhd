----------------------------------------------------------------------------
----                                                                    ----
----  File           : s3astarter_top.vhd                               ----
----  Project        : Spartan-3an starter kit: led test                ----
----  Creation       : 15. Mar. 2014                                    ----
----  Limitations    :                                                  ----
----  Synthesizer    : Xilinx                                           ----
----  Target         : Spartan-3an starter kit                          ----
----                                                                    ----
----  Author(s):     : Christian Haettich                               ----
----  Email          : feddischson@opencores.org                        ----
----                                                                    ----
----                                                                    ----
-----                                                                  -----
----                                                                    ----
----  Description                                                       ----
----    A very small design to test the Spartan-3an board.              ----
----    The intention was to have a small project to thest the tool-    ----
----    chain and the whole setup (synthese tools, usb-driver, cable    ----
----    connection)                                                     ----
----    This small design useses the rotatory-knob increase/decrease    ----
----    the LEDs. The center button is used to invert the LED's state   ----
-----                                                                  -----
----                                                                    ----
----                                                                    ----
----                                                                    ----
----                                                                    ----
----------------------------------------------------------------------------
----                                                                    ----
----                  Copyright Notice                                  ----
----                                                                    ----
---- Copyright (c) 2014, Author(s), All rights reserved.                ----
----                                                                    ----
---- This file is free software; you can redistribute it and/or         ----
---- modify it under the terms of the GNU Lesser General Public         ----
---- License as published by the Free Software Foundation; either       ----
---- version 3.0 of the License, or (at your option) any later version. ----
----                                                                    ----
---- This file is distributed in the hope that it will be useful,       ----
---- but WITHOUT ANY WARRANTY; without even the implied warranty of     ----
---- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU  ----
---- Lesser General Public License for more details.                    ----
----                                                                    ----
---- You should have received a copy of the GNU Lesser General Public   ----
---- License along with this library. If not, download it from          ----
---- http://www.gnu.org/licenses/lgpl                                   ----
----                                                                    ----
----------------------------------------------------------------------------



library ieee;
library std;
use std.textio.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity s3astarter_top is
port(
   CLK_50M  : in  std_logic;
   LED      : out std_logic_vector( 8-1 downto 0 );
   ROT_A			: in 	STD_LOGIC;
   ROT_B			: in  STD_LOGIC;
   ROT_CENTER	: in  STD_LOGIC;
   BTN_SOUTH   : in  STD_LOGIC
    );
end entity s3astarter_top;


architecture IMP of s3astarter_top is
  

   signal rst     : std_logic;

   -- debounce-counter
   -- 2^18 / 50 MHz is about 5.2 ms
   signal deb_cnt : unsigned( 18-1 downto 0 );

   -- debounced versions of input
   signal rot_a_deb  : std_logic;
   signal rot_b_deb  : std_logic;
   signal rot_c_deb  : std_logic;

   -- for edge detection
   signal rot_a_deb_last  : std_logic;
   signal rot_c_deb_last  : std_logic;

   -- led counter, wich is increased/decreased
   signal led_cnt : unsigned( 8-1 downto 0 );


begin

-- we use the south button as reset
rst <= BTN_SOUTH;



--
-- debounce the three inputs ROT_A, ROT_B, ROT_CENTER
-- with a 5.2 ms counter
-- 
debounce_p : process( CLK_50M )
begin
   if CLK_50M'event and CLK_50M='1' then
      if rst = '1' then
         deb_cnt <= ( others => '0' );
         rot_a_deb   <= ROT_A;
         rot_b_deb   <= ROT_B;
         rot_c_deb   <= ROT_CENTER;
      else
         deb_cnt <= deb_cnt+1;
         if deb_cnt = 0 then
            rot_a_deb <= ROT_A;
            rot_b_deb <= ROT_B;
            rot_c_deb <= ROT_CENTER;
         end if;
      end if;
   end if;
end process;


-- 
-- direction detection, when turning clock-wise: increase counter,
-- when turning counterclock wise: decrease counter,
-- when pressing center button: invert counter
rot_encode_p : process( CLK_50M )
begin
   if CLK_50M'event and CLK_50M='1' then
      if rst = '1' then
         rot_a_deb_last <= ROT_A;
         rot_c_deb_last <= ROT_CENTER;
         led_cnt        <= ( others => '0' );
      else
         rot_a_deb_last <= rot_a_deb;
         rot_c_deb_last <= rot_c_deb;
         if rot_a_deb = '1' and rot_a_deb_last = '0' then
            if rot_b_deb = '0' then
               led_cnt  <= led_cnt+1;
            else
               led_cnt  <= led_cnt-1;
            end if;
         end if;
         if rot_c_deb = '1' and rot_c_deb_last = '0' then
            led_cnt <= not led_cnt;
         end if;
      end if;
   end if;
end process;


LED <= std_logic_vector( led_cnt );


end architecture IMP;
