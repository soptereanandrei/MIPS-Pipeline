----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/22/2021 12:37:56 PM
-- Design Name: 
-- Module Name: Instruction_Fetch - Behavioral
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

entity Instruction_Fetch is
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           Jump : in STD_LOGIC;
           jump_addr : in STD_LOGIC_VECTOR (12 downto 0);
           PCSrc : in STD_LOGIC;
           branch_addr : in STD_LOGIC_VECTOR (15 downto 0);
           instruction : out STD_LOGIC_VECTOR (15 downto 0);
           PC : out STD_LOGIC_VECTOR (15 downto 0));
end Instruction_Fetch;

architecture Behavioral of Instruction_Fetch is

type mem_type is array(0 to 30) of STD_LOGIC_VECTOR(15 downto 0);
--signal INSTR : mem_type := (
---- op_rs_rt_rd_func
--B"000_010_011_001_0_000", --add: RF[$rd] = RF[$rs] + RF[$rt]
--B"000_010_011_001_0_001", --sub: RF[$rd] = RF[$rs] - RF[$rt]
--B"000_010_011_001_0_010", --sll: RF[$rd] = RF[$rs] << RF[$rt]
--B"000_010_011_001_0_011", --srl: RF[$rd] = RF[$rs] >> RF[$rt]
--B"000_010_011_001_0_100", --and: RF[$rd] = RF[$rs] and RF[$rt]
--B"000_010_011_001_0_101", --or: RF[$rd] = RF[$rs] or RF[$rt]
--B"000_010_001_000_0_110", --not: RF[$rd$1] = not RF[$rs]
--B"000_010_011_001_0_111", --mul: RF[$rd] = RF[$rs](7 downto 0) * RF[$rt](7 downto 0)
---- op_rs_rt_imm
--B"001_010_001_0000001", --addi: RF[$rt] = RF[$rs] + "0000001";
--B"010_010_001_0000001", --lw: RF[$rt] = MEM[RF[$rs] + "0000001"];
--B"011_010_001_0000001", --sw: MEM[RF[$rs] + "0000001"] = RF[$rt];
--B"100_001_010_0000010", --beq: if(RF[$rs] == RF[$rt]) then PC = PC + 1 + "0000010" else PC = PC + 1
--B"101_001_000_0000010", --bgez: if(RF[$rs] >= 0) then PC = PC + 1 + "0000010" else PC = PC + 1
--B"110_010_001_0000010", --slti: if(RF[$rs] < "0000010") then RF[$rt] = "1" else RF[$rt] = "0"
---- op target_addres
--B"111_0000000000111"    --j: PC = PC(15 downto 13) & "0000000000111"
--);

--signal PROGRAM_MEMORY : mem_type := (
----initializare
--B"001_000_001_0000010", --$1 = $0 + 2 -contor
--B"001_000_111_0001000",  --$7 = %0 + 8 --n limita
--B"001_000_010_0000001", --$2 = $0 + 1
--B"001_000_011_0000001", --$3 = $0 + 1
----loop
--B"000_010_011_100_0_000", --$4 = $2 + $3
--B"000_011_000_010_0_000",  --$2 = $3 + $0
--B"000_100_000_011_0_000",  --$3 = $4 + $0
--B"001_001_001_0000001",    --$1 = $1 + 1
--B"100_001_111_0000001",    --if (%1 == %7) PC = 11
--B"111_0000000000100",      --j 4
--B"011_000_100_0000000",    --MEM[$0 + 0] = $4
----fibonnacii(8) => mem(0) = 21
--B"000_100_100_001_0_111",  --$1 = $4 * $4
--B"011_000_001_0000001",    --MEM[$0 + 1] = $1
--B"010_000_001_0000000",    --$1 = MEM[$0 + 0];
--B"001_000_010_0000100",    --$2 = $0 + 4;
--B"000_001_010_001_0_010",  --$1 = $1 << $2
--others => x"0000"
--);

signal PROGRAM_MEMORY : mem_type := (
--initializare
B"001_000_001_0000010", --$1 = $0 + 2 -contor
B"001_000_111_0001000",  --$7 = %0 + 8 --n limita
B"001_000_010_0000001", --$2 = $0 + 1
B"001_000_011_0000001", --$3 = $0 + 1
B"000_000_000_000_0_000", --NoOperation
B"000_000_000_000_0_000", --NoOperation
--loop
B"000_010_011_100_0_000", --$4 = $2 + $3
B"001_001_001_0000001",    --$1 = $1 + 1
B"000_011_000_010_0_000",  --$2 = $3 + $0
B"000_100_000_011_0_000",  --$3 = $4 + $0
B"100_001_111_0000100",    --if (%1 == %7) PC = 15
B"000_000_000_000_0_000", --NoOperation
B"000_000_000_000_0_000", --NoOperation
B"000_000_000_000_0_000", --NoOperation
B"111_0000000000110",      --j 6
B"011_000_100_0000000",    --MEM[$0 + 0] = $4
--fibonnacii(8) => mem(0) = 21
B"000_100_100_001_0_111",  --$1 = $4 * $4
B"000_000_000_000_0_000",  --NoOperation
B"000_000_000_000_0_000",  --NoOperation
B"011_000_001_0000001",    --MEM[$0 + 1] = $1
B"010_000_001_0000000",    --$1 = MEM[$0 + 0];
B"001_000_010_0000100",    --$2 = $0 + 4;
B"000_000_000_000_0_000",  --NoOperation
B"000_000_000_000_0_000",  --NoOperation
B"000_001_010_001_0_010",  --$1 = $1 << $2
others => x"0000"
);

signal PC_REG : STD_LOGIC_VECTOR(15 downto 0) := (others=>'0');
signal PC_INC : STD_LOGIC_VECTOR(15 downto 0);
signal PC_INTER  : STD_LOGIC_VECTOR(15 downto 0);
signal PC_NEXT : STD_LOGIC_VECTOR(15 downto 0);

begin    
    PC_INC <= PC_REG + 1;
    
    with PCSrc select
        PC_INTER <= PC_INC when '0',
                    branch_addr when others;
                    
    with Jump select
        PC_NEXT <= PC_INTER when '0',
                    PC_INC(15 downto 13) & jump_addr when others;
                    
    REG: process (reset, clk)
    begin
        if (reset = '1') then
            PC_REG <= x"0000";
        elsif (clk'event and clk = '1') then
            if (enable = '1') then
                PC_REG <= PC_NEXT;
            end if;
        end if;
    end process;
    
    instruction <= PROGRAM_MEMORY(conv_integer(PC_REG));
    PC <= PC_INC;

end Behavioral;
