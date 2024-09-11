----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2024 10:43:09 PM
-- Design Name: 
-- Module Name: Program_Counter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Program_Counter is
    Port ( Reset : in STD_LOGIC;
           Clock : in STD_LOGIC;
           PC_in : in STD_LOGIC_VECTOR (2 downto 0);
           PC_out : out STD_LOGIC_VECTOR (2 downto 0) );
    end Program_Counter;

architecture Behavioral of Program_Counter is
--   COMPONENT Slow_Clk 
--       PORT( Clk_in : in STD_LOGIC;
--             Clk_out : out STD_LOGIC);
--   END COMPONENT;
   
   COMPONENT D_FF
          PORT(D : in STD_LOGIC;
               Res : in STD_LOGIC;
               Clk : in STD_LOGIC;
               Q : out STD_LOGIC;
               Qbar : out STD_LOGIC);
      END COMPONENT;
      
      signal FF_in : std_logic_vector(2 downto 0);  -- Internal signals 
--      signal Clk_slow : std_logic; -- Internal clock 

begin
--    Slow_Clk0 : Slow_Clk
--        port map (
--            Clk_in => Clock,
--            Clk_out => Clk_slow);
    
    D_FF0 : D_FF
         port map(
          D => PC_in(0),
          Res => Reset,
          Clk => Clock,                                
          Q => PC_out(0));                                                                   
            
     D_FF1:D_FF
         port map(           
         D => PC_in(1),               
         Res => Reset,
         Clk => Clock ,               
         Q => PC_out(1));   
                     
      D_FF2:D_FF
         port map(
           D => PC_in(2),
           Res => Reset,
           Clk => Clock ,
           Q => PC_out(2) ); 
                  
--   FF_in(0) <= PC_in(0);
--   FF_in(1) <= PC_in(1);
--   FF_in(2) <= PC_in(2);
   
--   FF_in(0) <= PC_in(0) AND NOT(Reset);
--   FF_in(1) <= PC_in(1) AND NOT(Reset);
--   FF_in(2) <= PC_in(2) AND NOT(Reset);
   

end Behavioral;
