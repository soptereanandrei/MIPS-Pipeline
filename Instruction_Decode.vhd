----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2021 01:11:00 PM
-- Design Name: 
-- Module Name: Instruction_Decode - Behavioral
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

entity Instruction_Decode is
    Port ( clk : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR (15 downto 0);
           RegWrite : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           WA : in STD_LOGIC_VECTOR(2 downto 0);
           WD : in STD_LOGIC_VECTOR (15 downto 0);
           RD1 : out STD_LOGIC_VECTOR (15 downto 0);
           RD2 : out STD_LOGIC_VECTOR (15 downto 0);
           Ext_imm : out STD_LOGIC_VECTOR (15 downto 0);
           sa : out STD_LOGIC_VECTOR (3 downto 0);
           func : out STD_LOGIC_VECTOR(2 downto 0)
           );
end Instruction_Decode;

architecture Behavioral of Instruction_Decode is

component REG_FILE
    Port ( clk : in STD_LOGIC;
           RegWr : in STD_LOGIC;
           RA1 : in STD_LOGIC_VECTOR (2 downto 0);
           RA2 : in STD_LOGIC_VECTOR (2 downto 0);
           WA : in STD_LOGIC_VECTOR (2 downto 0);
           WD : in STD_LOGIC_VECTOR (15 downto 0);
           RD1 : out STD_LOGIC_VECTOR (15 downto 0);
           RD2 : out STD_LOGIC_VECTOR (15 downto 0));
end component;

signal RD2_buffer : STD_LOGIC_VECTOR(15 downto 0);

begin
    REG : REG_FILE port map (clk => clk, RegWr => RegWrite, RA1 => Instr(12 downto 10), RA2 => Instr(9 downto 7), WA => WA, WD => WD, RD1 => RD1, RD2 => RD2_buffer); 
    RD2 <= RD2_buffer;
    
    Extend : process (Instr, ExtOp)
    begin
        if ExtOp = '1' then
            if Instr(6) = '0' then
                Ext_imm <= "000000000" & Instr(6 downto 0);
            else
                Ext_imm <= "111111111" & Instr(6 downto 0);
            end if; 
        else
            Ext_imm <= "000000000" & Instr(6 downto 0);
        end if;
    end process;

    sa <= RD2_buffer(3 downto 0);
    func <= Instr(2 downto 0);
    
end Behavioral;
