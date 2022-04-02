----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2021 08:56:22 PM
-- Design Name: 
-- Module Name: MPG - Behavioral
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

entity MPG is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           enable : out STD_LOGIC);
end MPG;

architecture Behavioral of MPG is

signal cnt : STD_LOGIC_VECTOR(15 downto 0) := (others=>('0'));
signal Q1, Q2, Q3 : STD_LOGIC := '0';

begin
    process (clk)
    begin
        if clk'event and clk = '1' then
            cnt <= cnt + 1;
        end if;
    end process;
    
    process (clk)
    begin
        if clk'event and clk = '1' then
            if cnt = x"ffff" then
                Q1 <= btn;
            end if;
        end if;
    end process;
    
    process (clk)
    begin
        if clk'event and clk = '1' then
            Q2 <= Q1;
            Q3 <= Q2;
        end if;
    end process;

    enable <= Q2 and (not Q3);

end Behavioral;
