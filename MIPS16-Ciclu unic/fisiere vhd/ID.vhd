----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2023 04:36:21 PM
-- Design Name: 
-- Module Name: ID - Behavioral
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

entity ID is
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
end ID;

architecture Behavioral of ID is

type REG_FILE is array(0 to 7) of STD_LOGIC_VECTOR(15 downto 0);
signal Reg: REG_FILE := (x"0000", x"0000", x"0000", x"0000", x"000A", others => x"0000"); 
signal WriteAddress : std_logic_vector(2 downto 0);

begin

process(RegDst, Instr(9 downto 7), Instr(6 downto 4))
begin
 case RegDst is
   when '0' => WriteAddress <= Instr(9 downto 7);
   when others => WriteAddress <= Instr(6 downto 4);
 end case;
end process; 

process(clk)
begin
if rising_edge(clk) then 
 if en='1' and RegWrite='1' then
   Reg(conv_integer(WriteAddress)) <= WD;
 end if;
end if;
end process;

RD1 <= Reg(conv_integer(Instr(12 downto 10)));
RD2 <= Reg(conv_integer(Instr(9 downto 7)));

with ExtOp select   
    Ext_Imm(15 downto 0) <= "000000000"& Instr(6 downto 0) when '0',
    Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6)&Instr(6 downto 0) when '1';

func <= Instr(2 downto 0);
sa <= Instr(3);     

end Behavioral;
