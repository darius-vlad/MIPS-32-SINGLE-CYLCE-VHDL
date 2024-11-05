----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2024 06:20:23 PM
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
 RD1 : in std_logic_vector(31 downto 0);
 ALUSrc : in std_logic;
 RD2: in std_logic_vector(31 downto 0);
 Ext_imm : in std_logic_vector(31 downto 0);
 sa : in std_logic_vector(4 downto 0);
 func : in std_logic_vector(5 downto 0);
 AluOp : in std_logic_vector(1 downto 0);
 PCplus : in std_logic_vector(31 downto 0);
 zero : out std_logic;
 AluRes : out std_logic_vector(31 downto 0);
 BranchAdress: out std_logic_vector(31 downto 0));
end EX;

architecture Behavioral of EX is
signal AluCtrl : std_logic_vector(3 downto 0);
signal AluOperand : std_logic_vector(31 downto 0);
signal auxalures : std_logic_vector(31 downto 0);
begin

process(AluOp,func)
begin
case AluOp is --aici facem opcode si function si alegem instructiune in functie de ele
when "10" => --Rtype
    case func is
    when "000000" =>AluCtrl <="0000";
    when "000001" =>AluCtrl <="0100";
    when "000010" => AluCtrl <="0001";
    when "000011" => AluCtrl <= "0011";
    when "000100" => AluCtrl <= "0110";
    when "000101" => AluCtrl <= "0010";
    when "000110" => AluCtrl <= "0111";
    when "000111" => AluCtrl <= "1000";
    when others =>AluCtrl <="0000";
    end case;
    
    when "00" => AluCtrl<="0000";
    when "01" => AluCtrl <= "0100";
    when "11" => AluCtrl <= "0010";
     when others =>AluCtrl <="0000";
    end case;
end process;

process(ALUSrc,RD2,Ext_imm)
begin
if ALUSrc = '0' then
ALUOperand <=RD2;
else
ALUOperand <=Ext_imm;
end if;
end process;

process(AluCtrl,sa,RD1,AluOperand,RD2,auxalures)
begin
case AluCtrl is 
when "0000" => 
  auxalures<=RD1+ALUOperand;
 
 when "0100" =>
   auxalures<=RD1-ALUOperand;
  
  when "0001" =>
  auxalures <= to_stdlogicvector(to_bitvector(RD1) sll conv_integer(sa));
  
  when "0011" =>
    auxalures <= to_stdlogicvector(to_bitvector(RD1) srl conv_integer(sa));
   
  when "0110" =>
      auxalures <= RD1 and ALUOperand;
   
  when "0010" =>
        auxalures <= RD1 or ALUOperand;
        
   when "0111" =>
         if RD1 < ALUOperand then
            auxalures <= x"00000001";
          else
           auxalures <= x"00000000";
           end if;
    
   when "1000" =>
       auxalures <= RD1 xor ALUOperand;    
    
  when others =>
  auxalures <=x"00000000";
end case;

end process;


AluRes <=auxalures;

process(auxalures)
begin
if auxalures = x"00000000"
then
zero <= '1';
else
zero <= '0';
end if;
end process;

process(Ext_imm,PCplus)
begin
BranchAdress <= (Ext_imm(29 downto 0) & "00") + PCplus;
end process;


end Behavioral;
