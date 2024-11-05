----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/01/2024 06:22:08 PM
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ID is
Port (
clk : in std_logic;
instr : in std_logic_vector(25 downto 0 );
regwr: in std_logic;
regdst: in std_logic;
extop: in std_logic;
enable : in std_logic;
rd1 : out std_logic_vector(31 downto 0);
rd2 : out std_logic_vector(31 downto 0);
wd : in std_logic_vector(31 downto 0);
ext_imm : out std_logic_vector(31 downto 0);
func : out std_logic_vector(5 downto 0);
sa : out std_logic_vector(4 downto 0));
end ID;

architecture Behavioral of ID is

component reg_file
Port(
clk : in std_logic;
ra1 : in std_logic_vector(4 downto 0);
ra2 : in std_logic_vector(4 downto 0);
wa : in std_logic_vector(4 downto 0);
wd : in std_logic_vector(31 downto 0);
enable : in std_logic;
regwr : in std_logic;
rd1 : out std_logic_vector(31 downto 0);
rd2 : out std_logic_vector(31 downto 0));
end component;
signal write_adress : std_logic_vector(4 downto 0);
begin
C1: reg_file port map(clk,instr(25 downto 21),instr(20 downto 16),write_adress,wd,enable,regwr,rd1,rd2);

process(regdst,instr)
begin
if regdst = '0' then write_adress <= instr(20 downto 16);
else
write_adress <= instr(15 downto 11);
end if;
end process;

process(extop,instr)
begin
ext_imm(15 downto 0) <= instr(15 downto 0);
if extop ='0'
then
ext_imm(31 downto 16) <= x"0000";
else
ext_imm(31 downto 16) <= (others => instr(15)) ;
end if;
end process;

func <= instr(5 downto 0);
sa <= instr(10 downto 6);

end Behavioral;
