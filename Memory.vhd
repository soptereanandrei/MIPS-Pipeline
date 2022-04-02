----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/12/2021 01:12:27 PM
-- Design Name: 
-- Module Name: Memory - Behavioral
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

entity Memory is
    Port ( clk : in STD_LOGIC;
           MemWrite : in STD_LOGIC;
           ALURes : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           MemData : out STD_LOGIC_VECTOR (15 downto 0);
           ALUResO : out STD_LOGIC_VECTOR (15 downto 0));
end Memory;

architecture Behavioral of Memory is

type ram_mem is array(0 to 256) of STD_LOGIC_VECTOR(15 downto 0);
signal mem : ram_mem := (
others => x"0000"
);

begin
    
    SyncWrite : process(clk) 
    begin
        if clk'event and clk = '1' then
            if MemWrite = '1' then
                mem(conv_integer(ALURes)) <= RD2;
            end if;
        end if;
    end process;

    MemData <= mem(conv_integer(ALURes(7 downto 0)));
    ALUResO <= ALURes;

end Behavioral;
