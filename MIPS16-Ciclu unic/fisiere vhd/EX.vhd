----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2023 04:26:42 PM
-- Design Name: 
-- Module Name: EX - Behavioral
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

entity EX is
  Port ( 
   RD1: in std_logic_vector(15 downto 0);  
   RD2: in std_logic_vector(15 downto 0);
   ALUSrc: in std_logic;
   Ext_Imm: in std_logic_vector(15 downto 0);
   sa: in std_logic;
   func: in std_logic_vector(2 downto 0);
   ALUOp: in std_logic_vector(2 downto 0);
   PCInc : in std_logic_vector(15 downto 0);
   Zero: out std_logic;
   ALURes: out std_logic_vector(15 downto 0);
   BranchAddress: out std_logic_vector(15 downto 0)
  );
end EX;

architecture Behavioral of EX is

signal ALUIn2 : std_logic_vector(15 downto 0);
signal ALUCtrl : std_logic_vector(2 downto 0);
signal ALURess : std_logic_vector(15 downto 0);

begin

mux : process(ALUSrc, RD2, Ext_Imm)
      begin
       case ALUSrc is 
         when '0' => ALUIn2 <= RD2;
         when '1' => ALUIn2 <= Ext_Imm;
         when others => ALUIn2 <= x"0000";
       end case;
      end process;
      
ALU_Control:  process(ALUOp, func)
                 begin
                     case ALUOp is
                         when "000" => -- R type
                             case func is
                                 when "000" => ALUCtrl <= "000"; -- ADD
                                 when "001" => ALUCtrl <= "001"; -- SUB
                                 when "010" => ALUCtrl <= "010"; -- SLL
                                 when "011" => ALUCtrl <= "011"; -- SRL
                                 when "100" => ALUCtrl <= "100"; -- AND
                                 when "101" => ALUCtrl <= "101"; -- OR
                                 when "110" => ALUCtrl <= "110"; -- XOR
                                 when "111" => ALUCtrl <= "111"; -- SLLV
                                 when others => ALUCtrl <= (others => '0'); 
                             end case;
                         when "001" => ALUCtrl <= "000"; -- +   ADDI,LW,SW
                         when "010" => ALUCtrl <= "001"; -- -   BEQ
                         when "101" => ALUCtrl <= "100"; -- & ANDI
                         when "110" => ALUCtrl <= "101"; -- | ORI
                         when others => ALUCtrl <= (others => '0'); 
                     end case;
                 end process;
                 
ALU : process(ALUCtrl,RD1, ALUIn2, sa)
          begin
              case ALUCtrl is
                  when "000" =>   ALURess <= RD1 + ALUIn2;   -- ADD    
                  when "001" =>   ALURess <= RD1 - ALUIn2;  -- SUB
                  when "010" =>  case sa is  -- SLL
                                  when '1' => ALURess <= ALUIn2(14 downto 0) & '0';
                                  when '0' => ALURess <= ALUIn2;
                                  when others => ALURess <= (others => '0');
                                  end case;
                  when "011" => case sa is -- SRL
                                   when '1' => ALURess <= '0' & ALUIn2(15 downto 1);
                                   when '0' => ALURess <= ALUIn2;
                                   when others => ALURess <= (others => '0');
                                end case; 
                  when "100" => ALURess <= RD1 and ALUIn2; -- AND
                  when "101"=> ALURess <= RD1 or ALUIn2; -- OR
                  when "110"=> ALURess <= RD1 xor ALUIn2; -- XOR
                  when "111" =>   -- SLT 
                                   if signed(RD1) < signed(ALUIn2) then
                                      ALURess <= x"0001";
                                   else
                                      ALURess <= x"0000";
                                   end if;
                  when others => ALURess <= (others => '0');                                
              end case;      
          end process;
          
zeroFlag: process(ALURess)
          begin 
            if ALURess = x"0000" then 
               Zero <= '1';
            else 
               Zero <= '0';
            end if;
           end process;        

       ALURes <= ALURess;
       BranchAddress <= Ext_Imm + PCInc;
end Behavioral;
