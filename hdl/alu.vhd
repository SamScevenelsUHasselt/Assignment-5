--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     alu - Behavioural
-- Project Name:    HWSWCD
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20241126   VlJo       Initial version
--
--------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    
library work;
    use work.PKG_hwswcd.ALL;

entity alu is
    port(
        operator1 : in std_logic_vector(C_WIDTH-1 downto 0);
        operator2 : in std_logic_vector(C_WIDTH-1 downto 0);
        ALUOp : in std_logic_vector(2 downto 0);
        arith_logic_b : in STD_LOGIC;
        signed_unsigned_b : in STD_LOGIC;
        result : out std_logic_vector(C_WIDTH-1 downto 0);
        zero : out std_logic;
        equal : out std_logic;
        carryOut : out std_logic;
        x_lt_y_u : out std_logic;
        x_lt_y_s : out std_logic
    );
end entity ;

architecture Behavioural of alu is

    -- (DE-)LOCALISING IN/OUTPUTS
    signal operator1_i : std_logic_vector(C_WIDTH-1 downto 0);
    signal operator2_i : std_logic_vector(C_WIDTH-1 downto 0);
    signal ALUOp_i : std_logic_vector(2 downto 0);
    signal arith_logic_b_i : STD_LOGIC;
    signal signed_unsigned_b_i : STD_LOGIC;
    signal result_o : std_logic_vector(C_WIDTH-1 downto 0);
    signal zero_o : std_logic;
    signal equal_o : std_logic;
    signal carryOut_o : std_logic;
    signal x_lt_y_u_o : std_logic;
    signal x_lt_y_s_o : std_logic;

    --
    signal aluResult : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal temp_sign : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    
    -- intermediate adder signals
    signal addition_sum, subtraction_sum : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal addition_c, subtraction_c : STD_LOGIC_VECTOR(C_WIDTH downto 0);
    
    -- shift
    signal ShiLe: STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal ShiRi: STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal offset : natural range 0 to C_WIDTH-1;
    signal shift_right_input : STD_LOGIC;
    signal shift_right_input_vector : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);

    -- comparator
    signal op1_uint, op2_uint : integer;
    signal op1_int, op2_int : integer;
    signal x_lt_y_int, x_lt_y_uint : STD_LOGIC;
    signal x_lt_y : STD_LOGIC;

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    operator1_i <= operator1;
    operator2_i <= operator2;
    ALUOp_i <= ALUOp;
    arith_logic_b_i <= arith_logic_b;
    signed_unsigned_b_i <= signed_unsigned_b;

    result <= result_o;
    zero <= zero_o;
    equal <= equal_o;
    carryOut <= carryOut_o;
    x_lt_y_u <= x_lt_y_u_o;
    x_lt_y_s <= x_lt_y_s_o;

    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    zero_o <= '1' when aluResult = C_GND else '0';
    equal_o <= '1' when operator1_i = operator2_i else '0';
    carryOut_o <= addition_c(C_WIDTH) when ALUOp = "100" else subtraction_c(C_WIDTH);
    result_o <= aluResult;
    -- signo_o <= aluResult(C_WIDTH-1);
    x_lt_y_u_o <= x_lt_y_uint;
    x_lt_y_s_o <= x_lt_y_int;


    op1_uint <= to_integer(unsigned(operator1_i));
    op2_uint <= to_integer(unsigned(operator2_i));
    op1_int <= to_integer(signed(operator1_i));
    op2_int <= to_integer(signed(operator2_i));
    x_lt_y_uint <= '1' when op1_uint < op2_uint else '0';
    x_lt_y_int <= '1' when op1_int < op2_int else '0';
    x_lt_y <= x_lt_y_int when signed_unsigned_b_i = '0' else x_lt_y_uint;
    temp_sign <= C_GND(C_WIDTH-1 downto 1) & x_lt_y;


    offset <= to_integer(unsigned(operator2_i(C_REGCOUNT_LOG2-1 downto 0)));
    ShiLe <= std_logic_vector(shift_left(unsigned(operator1_i), offset));
    ShiRi <= std_logic_vector(shift_right(unsigned(operator1_i), offset));

    -- if it's logic, the 'and' with 0 forces a 0 to be shifted in
    -- otherwise the msb of the operator1 is shifted in
    shift_right_input <= operator1_i(operator1_i'high) and arith_logic_b_i;
    shift_right_input_vector <= (others => shift_right_input);



    -- MUX
    process(operator1_i, operator2_i, ALUOp_i, addition_sum, subtraction_sum, ShiLe, ShiRi, temp_sign)
    begin
        case(ALUOp_i) is
            when "000" => aluResult <= operator1_i and operator2_i;
            when "001" => aluResult <= operator1_i or operator2_i;
            when "010" => aluResult <= operator1_i xor operator2_i;
            when "011" => aluResult <= temp_sign;
            when "100" => aluResult <= addition_sum;
            when "101" => aluResult <= subtraction_sum;
            when "110" => aluResult <= ShiLe;
            when "111" => aluResult <= ShiRi;
            when others => aluResult <= operator1_i;
        end case ;       
    end process ;


    -------------------------------------------------------------------------------
    -- ARITHMETIC
    -------------------------------------------------------------------------------
    addition_c(0) <= '0';
    subtraction_c(0) <= '1';

    GEN : for i in 0 to C_WIDTH-1 generate
        addition_sum(i) <= operator1_i(i) XOR operator2_i(i) XOR addition_c(i);
        addition_c(i+1) <= (operator1_i(i) AND operator2_i(i)) OR (addition_c(i) AND (operator1_i(i) XOR operator2_i(i)));

        subtraction_sum(i) <= operator1_i(i) XOR not(operator2_i(i)) XOR subtraction_c(i);
        subtraction_c(i+1) <= (operator1_i(i) AND not(operator2_i(i))) OR (subtraction_c(i) AND (operator1_i(i) XOR not(operator2_i(i))));
    end generate;

end Behavioural;
