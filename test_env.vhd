----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2021 12:41:50 PM
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
use IEEE.STD_LOGIC_ARITH.ALL;
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
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG 
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           enable : out STD_LOGIC);
end component;

component SSD
     Port ( clk : in STD_LOGIC;
          number : in STD_LOGIC_VECTOR (15 downto 0);
          an : out STD_LOGIC_VECTOR (3 downto 0);
          cat : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component Instruction_Fetch
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           Jump : in STD_LOGIC;
           jump_addr : in STD_LOGIC_VECTOR (12 downto 0);
           PCSrc : in STD_LOGIC;
           branch_addr : in STD_LOGIC_VECTOR (15 downto 0);
           instruction : out STD_LOGIC_VECTOR (15 downto 0);
           PC : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component Instruction_Decode
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
end component;

component Instruction_Execute
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
end component;

component Memory
    Port ( clk : in STD_LOGIC;
           MemWrite : in STD_LOGIC;
           ALURes : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           MemData : out STD_LOGIC_VECTOR (15 downto 0);
           ALUResO : out STD_LOGIC_VECTOR (15 downto 0));
end component;

--Instruction_Fetch signals
signal reset, enable : STD_LOGIC;
signal PC : STD_LOGIC_VECTOR(15 downto 0);
signal instr : STD_LOGIC_VECTOR(15 downto 0);
---------------------------

--Control_Unit signals
signal RegWrite : STD_LOGIC := '0';
signal RegDst : STD_LOGIC := '0';
signal ExtOp : STD_LOGIC := '0';
signal BranchEQual : STD_LOGIC := '0';
signal BranchGEZero : STD_LOGIC := '0';
signal Jmp : STD_LOGIC := '0';
signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);
signal ALUSrc : STD_LOGIC_VECTOR(1 downto 0);
signal MemWrite : STD_LOGIC := '0';
signal MemToReg : STD_LOGIC := '0';
----------------------

--Instruction_Decoder signals
signal RD1 : STD_LOGIC_VECTOR(15 downto 0);
signal RD2 : STD_LOGIC_VECTOR(15 downto 0);
signal Ext_imm : STD_LOGIC_VECTOR(15 downto 0);
signal sa : STD_LOGIC_VECTOR(3 downto 0);
signal func : STD_LOGIC_VECTOR(2 downto 0);
-----------------------------

--Instruction_Execute signals
signal branch_addrs : STD_LOGIC_VECTOR(15 downto 0);
signal ALURes : STD_LOGIC_VECTOR(15 downto 0);
signal Zero_Flag : STD_LOGIC;
signal Positive_Flag : STD_LOGIC;
signal PCSrc : STD_LOGIC;
signal WriteAddress : STD_LOGIC_VECTOR(2 downto 0);
----------------------------

--Memory signals
signal MemData : STD_LOGIC_VECTOR(15 downto 0);
signal MemALURes : STD_LOGIC_VECTOR(15 downto 0);
----------------------------

--Write_Back signals
signal WD : STD_LOGIC_VECTOR(15 downto 0);
----------------------------

--General signals
signal result : STD_LOGIC_VECTOR(15 downto 0);
-----------------

--Pipeline registers
signal Regs_Enable : STD_LOGIC := '0';
signal IF_ID : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
signal IF_ID_Reg : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
signal ID_EX : STD_LOGIC_VECTOR(86 downto 0) := (others=>'0');
signal ID_EX_Reg : STD_LOGIC_VECTOR(86 downto 0) := (others=>'0');
signal EX_MEM : STD_LOGIC_VECTOR(57 downto 0) := (others=>'0');
signal EX_MEM_Reg : STD_LOGIC_VECTOR(57 downto 0) := (others=>'0');
signal MEM_WB : STD_LOGIC_VECTOR(36 downto 0) := (others=>'0');
signal MEM_WB_Reg : STD_LOGIC_VECTOR(36 downto 0) := (others=>'0');
-----------------

begin
    
    MPG_Reset : MPG port map(clk => clk, btn => btn(0), enable => reset);
    MPG_Enable : MPG port map(clk => clk, btn => btn(1), enable => enable);
    
    I_F : Instruction_Fetch port map (
        reset => reset, 
        clk => clk, 
        enable => enable, 
        Jump => Jmp, 
        jump_addr => IF_ID_Reg(12 downto 0), 
        PCSrc => PCSrc, 
        branch_addr => EX_MEM_Reg(50 downto 35), 
        instruction => instr, 
        PC => PC
        );
    
    IF_ID(31 downto 16) <= PC;
    IF_ID(15 downto 0) <= instr;
    IF_ID_RegWrite : process(clk)
    begin
        if clk'event and clk = '1' then
            if enable = '1' then
                IF_ID_Reg <= IF_ID;
            end if;
        end if;        
    end process;
    
    Control_Unit : process (IF_ID_Reg(15 downto 13))
    begin
        RegWrite <= '0';
        RegDst <= '0';
        ExtOp <= '0';
        BranchEQual <= '0';
        BranchGEZero <= '0';
        Jmp <= '0';
        ALUOp <= "00";
        ALUSrc <= "00";
        MemWrite <= '0';
        MemToReg <= '0';
        case IF_ID_Reg(15 downto 13) is
            when "000" =>   RegWrite <= '1';
                            RegDst <= '1';
                            
            when "001" =>   RegWrite <= '1';
                            ExtOp <= '1';
                            ALUOp <= "01";
                            ALUSrc <= "01";
                            
            when "010" =>   RegWrite <= '1';
                            ExtOp <= '1';
                            ALUOp <= "01";
                            ALUSrc <= "01";
                            MemToReg <= '1';
                            
            when "011" =>   ExtOp <= '1';
                            ALUOp <= "01";
                            ALUSrc <= "01";
                            MemWrite <= '1';
                            
            when "100" =>   ExtOp <= '1';
                            BranchEQual <= '1';
                            ALUOp <= "10";
                            
            when "101" =>   ExtOp <= '1';
                            BranchGEZero <= '1'; 
                            ALUOp <= "10";
                            ALUSrc <= "10";
                                  
            when "110" =>   RegWrite <= '1';
                            ExtOp <= '1';
                            ALUOp <= "11";
                            ALUSrc <= "01";
                            
            when "111" =>   Jmp <= '1';
            
            when others =>
        end case;
    end process;

    I_D : Instruction_Decode port map (
        clk => clk, 
        Instr => IF_ID_Reg(15 downto 0),
        RegWrite => MEM_WB_Reg(36), 
        ExtOp => ExtOp,
        WA => MEM_WB_Reg(2 downto 0), 
        WD => WD, 
        RD1 => RD1, 
        RD2 => RD2, 
        Ext_imm => Ext_imm, 
        sa => sa, 
        func => func
        );
        
    ID_EX(86) <= RegWrite;
    ID_EX(85) <= RegDst;
    ID_EX(84) <= BranchEQual;
    ID_EX(83) <= BranchGEZero;
    ID_EX(82 downto 81) <= ALUOp;
    ID_EX(80 downto 79) <= ALUSrc;
    ID_EX(78) <= MemWrite;
    ID_EX(77) <= MemToReg;
    ID_EX(76 downto 61) <= IF_ID_Reg(31 downto 16);
    ID_EX(60 downto 45) <= RD1;
    ID_EX(44 downto 29) <= RD2;
    ID_EX(28 downto 13) <= Ext_Imm;
    ID_EX(12 downto 9) <= sa;
    ID_EX(8 downto 6) <= func;
    ID_EX(5 downto 3) <= IF_ID_Reg(9 downto 7);
    ID_EX(2 downto 0) <= IF_ID_Reg(6 downto 4);
    ID_EX_RegWrite : process(clk)
    begin
        if clk'event and clk = '1' then
            if enable = '1' then
                ID_EX_Reg <= ID_EX;
            end if;
        end if;        
    end process;

    I_E : Instruction_Execute port map(
           ALUOp => ID_EX_Reg(82 downto 81),
           ALUSrc => ID_EX_Reg(80 downto 79),
           rs => ID_EX_Reg(60 downto 45),
           rt => ID_EX_Reg(44 downto 29),
           Ext_imm => ID_EX_Reg(28 downto 13),
           func => ID_EX_Reg(8 downto 6),
           sa => ID_EX_Reg(12 downto 9),
           next_addrs => ID_EX_Reg(76 downto 61),
           ALURes => ALURes,
           Zero_Flag => Zero_Flag,
           Positive_Flag => Positive_Flag,
           branch_addrs => branch_addrs
           );
    
    with ID_EX_Reg(85) select --RegDst
        WriteAddress <= ID_EX_Reg(5 downto 3) when '0',
                         ID_EX_Reg(2 downto 0) when others;
                         
    EX_MEM(57) <= ID_EX_Reg(86);
    EX_MEM(56) <= ID_EX_Reg(77);
    EX_MEM(55) <= ID_EX_Reg(84);
    EX_MEM(54) <= ID_EX_Reg(83);
    EX_MEM(53) <= ID_EX_Reg(78);
    EX_MEM(52) <= Zero_Flag;
    EX_MEM(51) <= Positive_Flag;
    EX_MEM(50 downto 35) <= branch_addrs;
    EX_MEM(34 downto 19) <= ALURes;
    EX_MEM(18 downto 3) <= ID_EX_REG(44 downto 29);
    EX_MEM(2 downto 0) <= WriteAddress;
    EX_MEM_RegWrite : process(clk)
        begin
            if clk'event and clk = '1' then
                if enable = '1' then
                    EX_MEM_Reg <= EX_MEM;
                end if;
            end if;        
        end process;
    
    PCSrc <= (EX_MEM_Reg(55) and EX_MEM_Reg(52)) or (EX_MEM_Reg(54) and EX_MEM_Reg(51));

    MEM : Memory port map (
        clk => clk, 
        MemWrite => EX_MEM_Reg(53), 
        ALURes => EX_MEM_Reg(34 downto 19), 
        RD2 => EX_MEM_Reg(18 downto 3), 
        MemData => MemData, 
        ALUResO => MemALURes
        );

    MEM_WB(36) <= EX_MEM_Reg(57);
    MEM_WB(35) <= EX_MEM_Reg(56);
    MEM_WB(34 downto 19) <= MemData;
    MEM_WB(18 downto 3) <= MemALURes;
    MEM_WB(2 downto 0) <= EX_MEM_Reg(2 downto 0);
    MEM_WB_RegWrite : process(clk)
            begin
                if clk'event and clk = '1' then
                    if enable = '1' then
                        MEM_WB_Reg <= MEM_WB;
                    end if;
                end if;        
            end process;

    with MEM_WB_Reg(35) select
        WD <=   MEM_WB_Reg(18 downto 3) when '0',
                MEM_WB_Reg(34 downto 19) when others;

    with sw(7 downto 5) select
        result <= instr when "000",
                  PC when "001",
                  RD1 when "010",
                  RD2 when "011",
                  Ext_imm when "100",
                  ALURes when "101",
                  MemData when "110",
                  WD when others;

    SSD_component : SSD port map (clk => clk, number => result, an => an, cat => cat); 
             

end Behavioral;
