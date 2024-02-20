----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2023 05:17:45 PM
-- Design Name: 
-- Module Name: InstructionFetch - Behavioral
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

entity InstructionFetch is
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
end InstructionFetch;

architecture Behavioral of InstructionFetch is

type tROM is array (0 to 255) of std_logic_vector(15 downto 0);
signal ROM : tROM := (
--se parcurge un sir de 10 numere si se face xor pe fiecare numar; daca rezultatul este zero, se face or 
--cu un alt numar si si se adauga la suma, altfel, se face and  cu un alt numar si apoi se adauga 
--rezultatul la suma si se salveaza suma in memorie 
B"000_000_000_001_0_000", --0010 --add $1, $0, $0 --adauga 0 in registrul 1 --i=0, contorul buclei
B"001_000_100_0001010", --220A ----addi $4, $0, 10 --stocheaza 10 in registrul 4 --numarul de iteratii(10)
B"000_000_000_010_0_000", --0020 --add $2, $0, $0 --stocheaza 0 in registrul 2 --initializarea indexului locatiei de memorie
B"000_000_000_101_0_000", --0050 --add $5, $0, $0 --stocheaza 0 in registrul 5 --aici se face suma, acum sum = 0
B"001_000_110_0000010", --2302 --addi $6, $0, 2 --stocheaza 2 in registrul 6 --numarul cu care se face xor
B"001_000_111_0000111", --2387 --addi $7, $0, 7 --stocheaza 7 in registrul 7 --numarul cu care se face or si and
B"100_100_001_0001011", --908B --beq $1, $4, 11 --se verifica daca s-au facut 10 iteratii si daca da, se sare in afara buclei
B"010_010_011_0000000", --4980 --lw $3, 0($2) -- se aduce in $3 elementul curent din sir
B"000_001_110_011_0_110", --0736 --xor $3, $3, $6 --se face XOR între elementul curent si numãrul dat
B"100_011_000_0000010", --8C02 --beq $3, $0, 2 --se verifica dacã rezultatul XOR este 0 si daca da, se va face OR, sarindu-se peste doua instructiuni
B"000_011_111_011_0_100", --0FB4 --and $3, $3, $7 --daca rezultatul nu e 0, se face AND între elementul curent si numãrul dat in $7
B"111_0000000001101", --E00D --J 13 --inca un jump ca sa sara peste OR
B"000_011_111_011_0_101", --0FB5 --or $3, $3, $7 --se face OR între elementul curent si numãrul dat in $7
B"000_101_111_101_0_000", --17D0 --add $5, $5, $3 --se adauga la suma partiala din $5 elementul din $3 obtinut prin OR sau AND
B"011_010_011_0000000", --6980 --sw $3, 0($2) --se salveazã noul element în memorie la adresa corespunzãtoare
B"001_010_010_0000001", --2901 --addi $2, $2, 1 --se adauga 1 in $2=indexul urmãtorului element din sir
B"001_001_001_0000001", --2481 --addi $1, $1, 1 --se adauga 1 in $1=contorul buclei; i=i+1
B"111_0000000000110", --E006 --j 6 --se face salt la începutul buclei
B"011_000_101_0000001", --6281 --sw $5, 1($0) --salvarea sumei în memorie la adresa 1
B"010_000_010_0000001", --4101 --lw $2, 1($0) --se aduce in registrul $2 valoarea din memorie de la adresa 1 pentru verifica
others =>x"0000");

signal Q : std_logic_vector(15 downto 0);
signal D : std_logic_vector(15 downto 0);
signal mux1 : std_logic_vector(15 downto 0);
signal mux2: std_logic_vector(15 downto 0);
signal add : std_logic_vector(15 downto 0);

begin

pc: process(clk)
begin
 if clk = '1' and clk'event then
   if Reset = '1' then
     Q <= x"0000";
   elsif En = '1' then
     Q <= D;
   end if;
  end if;
end process;

mux_1: process(PCSrc, BranchAddress, add)
begin
  case PCSrc is 
    when '0' => mux1 <= add ;
    when others => mux1 <= BranchAddress;
  end case;
end process;

mux_2: process(Jump, JumpAddress, mux1)
begin
 case Jump is
   when '0' => D <= mux1;
   when others => D <= JumpAddress;
 end case;
end process; 

add <= 1 + Q; 
NextAddress <= add;
Instruction <= ROM(conv_integer(Q(7 downto 0)));
end Behavioral;
