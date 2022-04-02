----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2021 09:57:10 PM
-- Design Name: 
-- Module Name: Instruction_Execute - Behavioral
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

entity Instruction_Execute is
    Port ( ALUOp : in STD_LOGIC_VECTOR (1 downto 0);
           ALUSrc : in STD_LOGIC_VECTOR (1 downto 0);
           rs : in STD_LOGIC_VECTOR (15 downto 0);
           rt : in STD_LOGIC_VECTOR (15 downto 0);
           Ext_imm : in STD_LOGIC_VECTOR (15 downto 0);
           func : in STD_LOGIC_VECTOR (2 downto 0);
           sa : in STD_LOGIC_VECTOR (3 downto 0);
           next_addrs : in STD_LOGIC_VECTOR (15 downto 0);
           ALURes : out STD_LOGIC_VECTOR (15 downto 0);
           Zero_Flag : out STD_LOGIC;
           Positive_Flag : out STD_LOGIC;
           branch_addrs : out STD_LOGIC_VECTOR (15 downto 0));
end Instruction_Execute;

architecture Behavioral of Instruction_Execute is

signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);
signal op2 : STD_LOGIC_VECTOR(15 downto 0);
signal r_add : STD_LOGIC_VECTOR(15 downto 0);
signal r_sub : STD_LOGIC_VECTOR(15 downto 0);
signal r_sll : STD_LOGIC_VECTOR(15 downto 0);
signal r_srl : STD_LOGIC_VECTOR(15 downto 0);
signal r_and : STD_LOGIC_VECTOR(15 downto 0);
signal r_or : STD_LOGIC_VECTOR(15 downto 0);
signal r_not : STD_LOGIC_VECTOR(15 downto 0);
signal r_mul : STD_LOGIC_VECTOR(15 downto 0);
signal result : STD_LOGIC_VECTOR(15 downto 0);
signal positive_result : STD_LOGIC;

begin

    --ALUControl
    ALUControl : process (ALUOp, func)
    begin
        if (ALUOp = "00") then
            ALUCtrl <= func;
       elsif ALUOp = "01" then
            ALUCtrl <= "000"; --addi | lw | sw => add
       else
            ALUCtrl <= "001"; --beq | bgeq | slti => sub
       end if;
    end process;
                                    
    with ALUSrc select
        op2 <= rt when "00",
               Ext_imm when "01",
               x"0000" when others;

    r_add <= rs + op2;
    r_sub <= rs - op2;
    with sa select
        r_sll <= rs(15 downto 0) when "0000",
                 rs(14 downto 0) & b"0" when "0001",
                 rs(13 downto 0) & b"00" when "0010",
                 rs(12 downto 0) & b"000" when "0011",
                 rs(11 downto 0) & b"0000" when "0100",
                 rs(10 downto 0) & b"0_0000" when "0101",
                 rs(9 downto 0) & b"00_0000" when "0110",
                 rs(8 downto 0) & b"000_0000" when "0111",
                 rs(7 downto 0) & b"0000_0000" when "1000",
                 rs(6 downto 0) & b"0_0000_0000" when "1001",
                 rs(5 downto 0) & b"00_0000_0000" when "1010",
                 rs(4 downto 0) & b"000_0000_0000" when "1011",
                 rs(3 downto 0) & b"0000_0000_0000" when "1100",
                 rs(2 downto 0) & b"0_0000_0000_0000" when "1101",
                 rs(1 downto 0) & b"00_0000_0000_0000" when "1110",
                 rs(0) & b"000_0000_0000_0000" when others;
    with sa select
        r_srl <= rs(15 downto 0) when "0000",
                 b"0" & rs(15 downto 1) when "0001",
                 b"00" & rs(15 downto 2) when "0010",
                 b"000" & rs(15 downto 3)  when "0011",
                 b"0000" & rs(15 downto 4)  when "0100",
                 b"0_0000" & rs(15 downto 5)  when "0101",
                 b"00_0000" & rs(15 downto 6)  when "0110",
                 b"000_0000" & rs(15 downto 7)  when "0111",
                 b"0000_0000" & rs(15 downto 8)  when "1000",
                 b"0_0000_0000" & rs(15 downto 9)  when "1001",
                 b"00_0000_0000" & rs(15 downto 10)  when "1010",
                 b"000_0000_0000" & rs(15 downto 11)  when "1011",
                 b"0000_0000_0000" & rs(15 downto 12)  when "1100",
                 b"0_0000_0000_0000" & rs(15 downto 13)  when "1101",
                 b"00_0000_0000_0000" & rs(15 downto 14)  when "1110",
                 b"000_0000_0000_0000" & rs(15) when others;
    r_and <= rs and op2;
    r_or <= rs or op2;
    r_not <= not rs;
    r_mul <= rs(7 downto 0) * op2(7 downto 0);

    with ALUCtrl select
        result <= r_add when "000",
                  r_sub when "001",
                  r_sll when "010",
                  r_srl when "011",
                  r_and when "100",
                  r_or when "101",
                  r_not when "110",
                  r_mul when others;

    positive_result <= '1' when result(15) = '0' else '0'; 

    ALURes <= result when ALUOp /= "11" else
              x"0001" when positive_result = '0' else
              x"0000";
              
    branch_addrs <= next_addrs + Ext_imm;
    
    Zero_Flag <= '1' when result = x"0000" else '0';
    Positive_Flag <= positive_result;
    
end Behavioral;
