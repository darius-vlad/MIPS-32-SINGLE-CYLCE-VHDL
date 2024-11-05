----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2024 04:48:09 PM
-- Design Name: 
-- Module Name: IFetch - Behavioral
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

entity IFetch is
   Port ( 
        jump: in std_logic;
        jumpAdress: in std_logic_vector(31 downto 0);
        PCSrc: in std_logic;
        BranchAdress: in std_logic_vector(31 downto 0);
        en: in std_logic;
        rst: in std_logic;
        clk: in std_logic;
        instruction: out std_logic_vector(31 downto 0);
        pc_4: out  std_logic_vector(31 downto 0)
    );
end IFetch;

architecture Behavioral of IFetch is
 type t_mem is array(0 to 31) of std_logic_vector(31 downto 0);
signal mem: t_mem := ( 
  B"000001_00000_00001_0000000000000001", --0 (X4010000) addi $1 , $0 , 1  => initializare contor parcurgere in registrul 1 cu valoarea 1
  B"000001_00000_00010_0000000000000000", --1 (X4020000) addi $2 , $0 , 0  => index locatie memorie elemente din vector in registrul 2 cu valoarea 0
  B"000010_00000_00011_0000000000000100", --2 (X8030004) lw $3 , 4($0)  => se incarca N in registrul 3 din memorie de la adresa 4
  B"000000_00000_00011_00100_00000_000000", --3 (X32000) add $4 , $0 , $3  => punem in registrul 4 continutul registrului 3 ( numarul maxim de iteratii)
  B"000001_00000_00101_0000000000000000", --4 (X4050000) addi $5 , $0 , 0  => in registrul 5 intializam maximul numerelor pare cu 0
  B"000001_00000_01000_0000000000000000", --5 (X4080000) addi $8 , $0 ,0  => un flag pentru slt , initializat cu 0
  B"000100_00001_00100_0000000000001010", --6 (X1024000A) beq $1 , $4 , 10 => verificam daca contorul este egal cu numarul maxim de iteratii ( in resigstrul 1 este contorul si in 4 numarul maxim de iteratii) , iar in cazul in care sunt egale se sare la instrucitunea 17
  B"000010_00010_00110_0000000000001100", --7 (X846000C) lw $6 , 12($2)  => incarcam in registrul 6 elementul din vector de la adresa 12 + offsetul dat de registrul 2 ( aici vom incarca la fiecare iteratie urmatorul element din vector)
  B"000001_00000_01010_0000000000000001", --8 (X40A0001) addi $10 ,  $0 , 1  => punem in registrul 10 valoarea 1
  B"000000_00110_01010_00111_00000_000100", --9 (XCA3804) and $7 , $6 , $10  => facem and intre registrul 6 adica numarul actual din vector si registrul 10 adica 1 pentru a afla paritatea
  B"000100_00111_01010_0000000000000011", --10 (X10EA0003) beq $7 , $10 , 3  => daca numarul nu este par se sare la instriuctiunea 14
  B"000000_00101_00110_01000_00000_000110", --11 (XA64006) slt $8 , $5 , $6  => daca maximul este mai mic decat valoarea curenta atunci in registrul 8 se va afla valoarea 1 , in caz contrar va fi 0 (in registrul 5 avem maximul , iar in registrul 6 avem numarul din vector)
  B"000100_01000_00000_0000000000000001", --12 (X11000001) beq $8 , $0 , 1  => daca valoarea din 8 este egala cu 0 atunci maximul nu se va schimba si se sare la instructiunea 14
  B"000000_00110_00000_00101_00000_000000", --13 (XC02800) add $5 , $6 , $0  => in caz in care in registrul 8 avem valoarea unu , vom pune in registrul 5 ( unde este continut maximul) , suma dintre registrul 6 ( numarul curent din vector) si registrul 0 ( cu valoare constanta 0)
  B"000001_00010_00010_0000000000000100", --14 (X4420004)  addi $2 , $2 , 4  => adaugam la registrul 2 numarul 4 pentru a putea trece la urmatorul element din vector
  B"000001_00001_00001_0000000000000001", --15 (X4210001) addi $1 , $1 , 1  => crestem contorul aflta la registrul 1 cu 1
  B"000111_00000000000000000000000110", --16 (X1C000006) j 6  => facem jump la instructiunea 6
  B"000011_00000_00101_0000000000001000", --17 (XC050006) sw $5 , 8($0) => dupa ce se termina toata parcurgerea salvam continutul registrului 5 ( maximul rezultat) la adresa 8
   B"000010_00000_01100_0000000000001000", --18 (X80C0008) lw $12 , 8($0)  => incarcam in registrul 12 ce am salvat la adresa 8 pentru a putea fi vizualizat in mem_data
    others => X"00000000"
);
signal Q :std_logic_vector(31 downto 0);
signal D:std_logic_vector(31 downto 0);
--signal B: std_logic_vector(31 downto 0);
signal sum: std_logic_vector(31 downto 0);
signal mux1: std_logic_vector(31 downto 0);
--signal mux2: std_logic_vector(31 downto 0);
begin
pc:
process(clk,rst)
begin 
  if rst='1' then 
    Q<=X"00000000";
  elsif rising_edge(clk) then
     if en='1' then
     Q<=D;
    end if;
   end if;
end process;

instruction<=mem(conv_integer(Q(6 downto 2)));
sum<=Q+4;
mux_1:
process(PCSrc,BranchAdress,sum)
begin 
case PCSrc is
when '0' => mux1<= Q+4;
when '1' => mux1<=BranchAdress;
when others => mux1<=X"00000000";
end case;
end process;

mux_2: 
process(jump,jumpAdress,mux1)
begin 
case jump is
when '0' => D<=mux1;
when '1' =>D<=jumpAdress;
when others => D<=X"00000000";
end case;
end process;

pc_4<=sum;

end Behavioral;