----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2023 05:42:50 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
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

entity MEM is
    port ( 
           MemWrite : in STD_LOGIC;	
           ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);		
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR(15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end MEM;

architecture Behavioral of MEM is

type DataMemory is array( 0 to 31) of std_logic_vector(15 downto 0);
signal MEM: DataMemory := (x"0008", x"0002", x"0005", x"000A", x"000B", x"000F", x"000B", x"000E", x"0004", x"0002", 
          others => x"0000");

begin
    process(clk)
    begin
        if clk='1' and clk'event then
            if en='1' and MemWrite='1' then
                MEM(conv_integer(ALUResIn(4 downto 0))) <= RD2;
            end if;
       end if;
    end process; 
    
    MemData <= MEM(conv_integer(ALUResIn(4 downto 0)));
    ALUResOut <= ALUResIn;
end Behavioral;
