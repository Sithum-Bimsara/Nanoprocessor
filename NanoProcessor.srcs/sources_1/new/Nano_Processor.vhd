----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2024 07:37:11 PM
-- Design Name: 
-- Module Name: Nano_Processor - Behavioral
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

entity Nano_Processor is
    Port( Reset : in STD_LOGIC;
          Clk_in : in STD_LOGIC;
          Overflow : out STD_LOGIC;
          ZERO : out STD_LOGIC;
          Reg7_Value : out STD_LOGIC_VECTOR (3 downto 0);
          Seven_Segment_Out : out STD_LOGIC_VECTOR (6 downto 0);
          Anode : out STD_LOGIC_VECTOR(3 downto 0));
end Nano_Processor;

architecture Behavioral of Nano_Processor is

    component Instruction_Decoder is
    Port ( Instruction_Bus : in STD_LOGIC_VECTOR (11 downto 0);
           Jump_Check : in STD_LOGIC_VECTOR (3 downto 0);
           Immediate_Value : out STD_LOGIC_VECTOR (3 downto 0);
           Load_Select : out STD_LOGIC;
           Add_Sub_Select : out STD_LOGIC;
           Reg_Sel_MUX_A : out STD_LOGIC_VECTOR (2 downto 0);
           Reg_Sel_MUX_B : out STD_LOGIC_VECTOR (2 downto 0);
           Reg_Enable : out STD_LOGIC_VECTOR (2 downto 0);
           Jump_Flag : out STD_LOGIC;
           Jump_Address : out STD_LOGIC_VECTOR (2 downto 0));
    end component;
    
    component Program_ROM is
        Port ( Memory_Select : in STD_LOGIC_VECTOR (2 downto 0);
               Instruction : out STD_LOGIC_VECTOR (11 downto 0));
    end component;
    
    component Register_Bank is
        Port ( Register_Enable : in STD_LOGIC_VECTOR (2 downto 0);
               Clock : in STD_LOGIC;
               Register_0_output : out STD_LOGIC_VECTOR (3 downto 0);
               Register_1_output : out STD_LOGIC_VECTOR (3 downto 0);
               Register_2_output : out STD_LOGIC_VECTOR (3 downto 0);
               Register_3_output : out STD_LOGIC_VECTOR (3 downto 0);
               Register_4_output : out STD_LOGIC_VECTOR (3 downto 0);
               Register_5_output : out STD_LOGIC_VECTOR (3 downto 0);
               Register_6_output : out STD_LOGIC_VECTOR (3 downto 0);
               Register_7_output : out STD_LOGIC_VECTOR (3 downto 0);
               Multiplexer_2_way_4_bit_output : in STD_LOGIC_VECTOR (3 downto 0);
               Reset : in STD_LOGIC);
    end component;
    
    component Adder_Subtractor_4_bit is
        Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
               B : in STD_LOGIC_VECTOR (3 downto 0);
               ADD_SUB_SELECT : in STD_LOGIC;
               Overflow : out STD_LOGIC;
               Zero : out STD_LOGIC;
               S : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    component Multiplexer_8_way_4_bit is
        Port ( Register_Select : in STD_LOGIC_VECTOR (2 downto 0);
               Register_0_output : in STD_LOGIC_VECTOR (3 downto 0);
               Register_1_output : in STD_LOGIC_VECTOR (3 downto 0);
               Register_2_output : in STD_LOGIC_VECTOR (3 downto 0);
               Register_3_output : in STD_LOGIC_VECTOR (3 downto 0);
               Register_4_output : in STD_LOGIC_VECTOR (3 downto 0);
               Register_5_output : in STD_LOGIC_VECTOR (3 downto 0);
               Register_6_output : in STD_LOGIC_VECTOR (3 downto 0);
               Register_7_output : in STD_LOGIC_VECTOR (3 downto 0);
               Multiplexer_8_way_4_bit_output : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    component Multiplexer_2_way_4_bit is
        Port ( Immediate_value_from_ID : in STD_LOGIC_VECTOR (3 downto 0);
               Output_of_4_bit_Add_Sub_Unit : in STD_LOGIC_VECTOR (3 downto 0);
               Load_select : in STD_LOGIC;
               Multiplexer_2_way_4_bit_output : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    component Adder_3_Bit is
        Port ( A : in STD_LOGIC_VECTOR (2 downto 0);
               C_in : in STD_LOGIC;
               S : out STD_LOGIC_VECTOR (2 downto 0) );
    end component;
    
    component Multiplexer_2_way_3_bit is
        Port ( Adder_3_bit_input : in STD_LOGIC_VECTOR (2 downto 0);
               Address_to_jump : in STD_LOGIC_VECTOR (2 downto 0);
               Jump_Flag : in STD_LOGIC;
               Mux_2_way_3_bit_output : out STD_LOGIC_VECTOR (2 downto 0));
    end component;

    component Program_Counter is
    Port ( Reset : in STD_LOGIC;
           Clock : in STD_LOGIC;
           PC_in : in STD_LOGIC_VECTOR (2 downto 0);
           PC_out : out STD_LOGIC_VECTOR (2 downto 0) );
    end component;
    
    component Slow_Clk is
        Port ( Clk_in : in STD_LOGIC;
               Clk_out : out STD_LOGIC);
    end component;
    
    component Seven_Segment_Display is
        Port ( number : in STD_LOGIC_VECTOR (3 downto 0);
               display : out STD_LOGIC_VECTOR (6 downto 0));
    end component;
    
    signal Slow_Clock : STD_LOGIC;
    signal PC_out : STD_LOGIC_VECTOR (2 downto 0);
    signal Adder_3_Bit_Output : STD_LOGIC_VECTOR (2 downto 0);
    signal Mux_2_way_3_bit_Output : STD_LOGIC_VECTOR (2 downto 0);
    signal ROM_Out : STD_LOGIC_VECTOR (11 downto 0);
    signal Reg_Sel_MUX_A, Reg_Sel_MUX_B, Reg_Enable, Jump_Address : STD_LOGIC_VECTOR (2 downto 0);
    signal Immediate_Value : STD_LOGIC_VECTOR (3 downto 0);
    signal Load_Select, Add_Sub_Select, Jump_Flag : STD_LOGIC;
    signal Overflow_0 : STD_LOGIC;
    signal Reg_0, Reg_1, Reg_2, Reg_3, Reg_4, Reg_5, Reg_6, Reg_7, MUX_A_Out, MUX_B_Out, MUX_2_to_1_out, RCA_out : STD_LOGIC_VECTOR (3 downto 0); 
    
    
begin

    Slow_Clk_0 : Slow_Clk
        port map (
            Clk_in => Clk_in,
            Clk_out => Slow_Clock);
            
    Adder_3_bit_0 : Adder_3_bit
        port map (
            A => PC_out,
            C_in => '0',
            S => Adder_3_Bit_Output);
            
    Program_Counter_0 : Program_Counter
        port map (
            Reset => Reset,
            Clock => Slow_Clock,
            PC_in => Mux_2_way_3_bit_Output,
            PC_out => PC_out);
            
    Adder_Subtractor_4_bit_0 : Adder_Subtractor_4_bit 
        port map (
            A => MUX_A_Out,
            B => MUX_B_Out,
            ADD_SUB_SELECT => Add_Sub_Select,
            Overflow => Overflow_0,
            Zero => Zero,
            S => RCA_out);
            
    MUX_A : Multiplexer_8_way_4_bit 
        port map (
            Register_Select => Reg_Sel_MUX_A,
            Register_0_output => Reg_0,
            Register_1_output => Reg_1,
            Register_2_output => Reg_2,
            Register_3_output => Reg_3,
            Register_4_output => Reg_4,
            Register_5_output => Reg_5,
            Register_6_output => Reg_6,
            Register_7_output => Reg_7,
            Multiplexer_8_way_4_bit_output => MUX_A_Out );
            
    MUX_B : Multiplexer_8_way_4_bit 
        port map (
            Register_Select => Reg_Sel_MUX_B,
            Register_0_output => Reg_0,
            Register_1_output => Reg_1,
            Register_2_output => Reg_2,
            Register_3_output => Reg_3,
            Register_4_output => Reg_4,
            Register_5_output => Reg_5,
            Register_6_output => Reg_6,
            Register_7_output => Reg_7,
            Multiplexer_8_way_4_bit_output => MUX_B_Out );
            
    Register_Bank_0 : Register_Bank
        port map (
            Register_Enable => Reg_Enable,
            Clock => Slow_Clock,
            Register_0_output => Reg_0,
            Register_1_output => Reg_1,
            Register_2_output => Reg_2,
            Register_3_output => Reg_3,
            Register_4_output => Reg_4,
            Register_5_output => Reg_5,
            Register_6_output => Reg_6,
            Register_7_output => Reg_7,
            Multiplexer_2_way_4_bit_output => MUX_2_to_1_out,
            Reset => Reset );
            
    MUX_2_way_3_bit : Multiplexer_2_way_3_bit
        port map (
            Adder_3_bit_input => Adder_3_Bit_Output,
            Address_to_jump => Jump_Address,
            Jump_Flag => Jump_Flag,
            Mux_2_way_3_bit_output => Mux_2_way_3_bit_Output);
            
    MUX_2_way_4_bit : Multiplexer_2_way_4_bit
        port map (
            Immediate_value_from_ID => Immediate_Value,
            Output_of_4_bit_Add_Sub_Unit => RCA_out,
            Load_select => Load_Select,
            Multiplexer_2_way_4_bit_output => MUX_2_to_1_out );
            
    Instruction_Decoder_0 : Instruction_Decoder 
        port map (
            Instruction_Bus => ROM_Out,
            Jump_Check => MUX_B_Out,
            Immediate_Value => Immediate_Value,
            Load_Select => Load_Select,
            Add_Sub_Select => Add_Sub_Select,
            Reg_Sel_MUX_A => Reg_Sel_MUX_A,
            Reg_Sel_MUX_B => Reg_Sel_MUX_B,
            Reg_Enable => Reg_Enable,
            Jump_Flag => Jump_Flag,
            Jump_Address => Jump_Address);
            
    Program_ROM_0 : Program_ROM 
        port map (
            Memory_Select => PC_Out,
            Instruction => ROM_Out);
            
    Seven_Segement_Display_0 : Seven_Segment_Display 
        port map (
            number => Reg_7,
            display => Seven_Segment_Out);
         
    Reg7_Value <= Reg_7;        
    Overflow <= Overflow_0;
    Anode <= "1110";
    
end Behavioral;
