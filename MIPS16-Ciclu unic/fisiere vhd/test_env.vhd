----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/07/2023 02:36:21 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

component SSD is
    Port ( an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           digit : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC);
end component;

component ID is
      Port(
      clk : in std_logic;
      en : in std_logic;
      Instr : in std_logic_vector(15 downto 0);
      WD : in std_logic_vector(15 downto 0);
      RegWrite : in std_logic;
      RegDst : in std_logic;
      ExtOp : in std_logic;
      RD1: out std_logic_vector(15 downto 0);
      RD2 : out std_logic_vector(15 downto 0);
      Ext_Imm : out std_logic_vector(15 downto 0);
      func : out std_logic_vector(2 downto 0);
      sa : out std_logic
      );
end component;

component InstructionFetch is
Port (
Jump : in std_logic;
JumpAddress : in std_logic_vector(15 downto 0);
BranchAddress : in std_logic_vector(15 downto 0);
PCSrc : in std_logic;
En : in std_logic;
Reset : in std_logic;
clk : in std_logic;
Instruction : out std_logic_vector(15 downto 0);
NextAddress : out std_logic_vector (15 downto 0)); --PC+1
end component;

component MainControl is
   Port ( 
   Instr : in std_logic_vector(15 downto 0);
   RegDst : out std_logic;
   ExtOp : out std_logic;
   ALUSrc : out std_logic;
   Branch : out std_logic;
   Jump : out std_logic;
   ALUOp : out std_logic_vector(2 downto 0);
   MemWrite : out std_logic;
   MemtoReg : out std_logic;
   RegWrite : out std_logic);
end component;

component EX is
  Port ( 
   RD1: in std_logic_vector(15 downto 0);  
   RD2: in std_logic_vector(15 downto 0);
   ALUSrc: in std_logic;
   Ext_Imm: in std_logic_vector(15 downto 0);
   sa: in std_logic;
   func: in std_logic_vector(2 downto 0);
   ALUOp: in std_logic_vector(2 downto 0); --cod pt operatia alu 
   PCInc : in std_logic_vector(15 downto 0);
   Zero: out std_logic;
   ALURes: out std_logic_vector(15 downto 0);
   BranchAddress: out std_logic_vector(15 downto 0)
  );
end component;

component MEM is
    port ( 
           MemWrite : in STD_LOGIC;	
           ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);		
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR(15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end component;

--MIPS

signal en : std_logic;
signal en1: std_logic;
signal BranchAddress : std_logic_vector(15 downto 0); 
signal Instruction : std_logic_vector(15 downto 0);
signal NextAddress : std_logic_vector(15 downto 0);
signal digits: std_logic_vector(15 downto 0);
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite :  std_logic;
signal ALUOp : std_logic_vector(2 downto 0);
signal RD1, RD2, Ext_Imm : std_logic_vector(15 downto 0);
signal func : std_logic_vector(2 downto 0); 
signal func1 : std_logic_vector(15 downto 0);
signal sa : std_logic;
signal sa1 : std_logic_vector(15 downto 0);
signal WD : std_logic_vector(15 downto 0);
signal ALURes : std_logic_vector(15 downto 0);
signal Zero : std_logic;
signal MemData, ALUResOut : std_logic_vector(15 downto 0);
signal JumpAddress : std_logic_vector(15 downto 0);
signal PCSrc : std_logic;

begin

--MIPS

debouncer : MPG port map(en, btn(0), clk);
debouncer1 : MPG port map(en1, btn(1), clk);


JumpAddress <= NextAddress(15 downto 13) & Instruction(12 downto 0);
PCSrc <= Zero and Branch;
instrFetch : InstructionFetch port map(Jump, JumpAddress, BranchAddress, PCSrc, en, en1, clk, Instruction, NextAddress);
main : MainControl port map(Instruction, RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);
decode : ID port map(clk, en, Instruction, WD, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_Imm, func, sa);
execution : EX port map(RD1, RD2, ALUSrc, Ext_Imm, sa, func, ALUOp, NextAddress, Zero, ALURes, BranchAddress);
memorie : MEM port map(MemWrite, ALURes, RD2, clk, en, MemData, ALUResOut);

mux_WB : process(MemtoReg, ALUResOut, MemData)
         begin
          case MemtoReg is 
            when '0' => WD <= ALUResOut;
            when others => WD <= MemData;
         end case;
         end process;
         
func1 <= "0000000000000" & func;
sa1 <= "000000000000000" & sa;

led(10 downto 0) <= ALUop & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemToReg & RegWrite;

mux : process(sw(7 downto 5), Instruction, NextAddress, RD1, RD2, WD, Ext_Imm, func1, sa1)
      begin
      case sw(7 downto 5) is
        when "000" =>  digits <= Instruction;
        when "001" =>  digits <= NextAddress;
        when "010" =>  digits <= RD1;
        when "011" =>  digits <= RD2;
        when "100" =>  digits <= Ext_Imm;
        when "101" =>  digits <= ALURes;
        when "110" =>  digits <= MemData;
        when "111" =>  digits <= WD;
        when others => digits <= (others => '0');
      end case;
     end process;
     
display : SSD port map(an, cat, digits, clk);

end Behavioral;
