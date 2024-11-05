----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2024 06:22:39 PM
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
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
         
end test_env;

architecture Behavioral of test_env is
component MPG
Port ( en : out  STD_LOGIC; 
input : in STD_LOGIC; 
clock : in  STD_LOGIC); 
end component; 

component SSD
Port(
   clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component reg_file
port ( clk : in std_logic;
ra1 : in std_logic_vector(4 downto 0);
ra2 : in std_logic_vector(4 downto 0);
wa : in std_logic_vector(4 downto 0);
wd : in std_logic_vector(31 downto 0);
regwr : in std_logic;
rd1 : out std_logic_vector(31 downto 0);
rd2 : out std_logic_vector(31 downto 0));
end component;

component ram_wr_1st
port ( clk : in std_logic;
we : in std_logic;
en : in std_logic;
addr : in std_logic_vector(5 downto 0);
di : in std_logic_vector(31 downto 0);
do : out std_logic_vector(31 downto 0));
end component;

component IFetch
Port (
  jump: in std_logic;
  jumpAdress: in std_logic_vector(31 downto 0);
  PcSrc: in std_logic;
  BranchAdress: in std_logic_vector(31 downto 0);
  en: in std_logic;
  rst: in std_logic;
  clk : in std_logic;
  instruction: out std_logic_vector(31 downto 0);
  pc_4 : out std_logic_vector(31 downto 0));
   end component;

component ID 
Port(clk : in std_logic;
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
end component;



component EX 
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
end component;

component MEM is
Port (
   MemWrite : in STD_LOGIC;
           ALURes : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal cnt: STD_LOGIC_VECTOR(5 downto 0);
signal enable : STD_LOGIC;
signal digits : std_logic_vector(31 downto 0);
signal jump : std_logic;
signal pcsrc : std_logic;
signal mux_sel : std_logic_vector(2 downto 0);
signal jumpAdress  : std_logic_vector(31 downto 0);
signal AluRes :  std_logic_vector(31 downto 0);
signal BranchAdress:  std_logic_vector(31 downto 0);
signal reset : std_logic;
signal instruction: std_logic_vector(31 downto 0);
signal PCplus : std_logic_vector(31 downto 0);
signal regwr: std_logic;
signal regdst : std_logic;
signal extop : std_logic;
signal rd1: std_logic_vector(31 downto 0);
signal rd2: std_logic_Vector(31 downto 0);
signal write_data : std_logic_vector(31 downto 0);
signal ext_imm : std_logic_vector(31 downto 0);
signal fc : std_logic_vector(5 downto 0);
signal sa : std_logic_vector(4 downto 0);
signal alusrc : std_logic;
signal aluop : std_logic_vector(1 downto 0);
signal zero : std_logic;
signal memWrite : std_logic;
signal mem_data : std_logic_vector(31 downto 0);
signal branch : std_logic;
signal bgtz : std_logic;
signal memToReg : std_logic;

begin
c1 : MPG port map(enable,btn(0),clk);

c2 : SSD port map(clk,digits,an,cat);

C3: IFetch port map(jump , jumpAdress , pcsrc , BranchAdress , enable , btn(1) , clk , instruction , PCplus);

C4: ID port map(clk,instruction(25 downto 0),regwr,regdst,extop,enable,rd1,rd2,write_data,ext_imm,fc,sa);

c5: EX port map(rd1,alusrc,rd2,ext_imm,sa,fc,aluop,PCplus,zero, AluRes,BranchAdress);

C6: MEM port map(memWrite , AluRes , rd2 , clk , enable , mem_data , AluRes);

mux_sel <= sw(15) & sw(14) & sw(13);
led <= sw;
 jumpAdress <= PCplus(31 downto 28) & instruction(25 downto 0) & "00";

process(mux_sel,instruction,PCPlus,rd1,rd2,ext_imm)
begin
case mux_sel is
when "000" => digits<= instruction;
when "001" => digits <=PCPlus;
when "010" => digits <=rd1;
when "011" => digits <=rd2;
when "100" => digits <= ext_imm;
when "101" => digits <= AluRes ;
when "110" => digits <= mem_data;
when "111" => digits <= write_data;
end case;
end process;

process(instruction)
begin

jump <= '0';
regdst <= '0';
regwr <= '0';
extop <= '0';
alusrc <= '0';
branch <= '0';
bgtz <= '0';
memWrite <= '0';
memToReg <= '0';
aluop <= "00";
case instruction(31 downto 26) is
when "000000" => regdst <= '1';
                 regwr <= '1';
                 extop <= 'X';
                aluop <= "10";
                
when "000001" => extop <= '1';
                 alusrc <= '1';
                 regwr <= '1';
                 aluop <= "00";   
                    
when "000010" => extop <= '1';
                 alusrc <= '1';
                 memToReg <= '1';
                 regwr <= '1';
                 aluop <= "00";
                 
when "000011" => regdst <= 'X';
                 extop <= '1';
                 alusrc <= '1';
                 memWrite <= '1';
                 memToReg <= 'X';
                 aluop <= "00";
                 
when "000100" => regdst <= 'X';
                 extop <= '1';
                 branch <= '1';
                 memToReg <= 'X';
                 aluop <= "01";
                 
when "000101" => alusrc <= '1';
                regwr <= '1';
                extop <= '1';
                regdst <= '1';
                aluop <= "11";
                
when "000110" => regdst <= 'X';
                 extop <= '1';
                 bgtz <= '1';
                 memToReg <= 'X';
                 aluop <= "01";
                 
when "000111" => regdst <= 'X';
                 extop <= 'X';
                 alusrc <= 'X';
                 jump <= '1';
                 memToReg <= 'X';
                 aluop <= "10";
                                                 
 when others => jump <= 'X';
regdst <= 'X';
regwr <= 'X';
extop <= 'X';
alusrc <= 'X';
branch <= 'X';
bgtz <= 'X';
memWrite <= 'X';
memToReg <= 'X';
aluop <= "XX";
 end case;
 end process;


process(memToReg) 
begin 
if memToReg = '0' then
write_data <= AluRes ;
else
write_data <= mem_data;
end if;
end process;

process(branch , zero)
begin
pcsrc <= branch and zero;
end process;

end Behavioral;
