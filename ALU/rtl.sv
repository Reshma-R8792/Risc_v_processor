
module alu #(parameter int DATA_WIDTH = 32)(
    input  logic [4:0]              alu_control,
    input  logic [DATA_WIDTH-1:0]   rs1_data,
    input  logic [DATA_WIDTH-1:0]   rs2_data,
    output logic [DATA_WIDTH-1:0]   alu_out,
    output logic                    zero
);

    always_comb begin
        // Default values
        alu_out = '0;
        zero    = 1'b0;

        case (alu_control)

            // Arithmetic operations
            5'b00000: alu_out = rs1_data + rs2_data; // ADD
            5'b00001: alu_out = rs1_data - rs2_data; // SUB

            // Logic operations
            5'b00010: alu_out = rs1_data ^ rs2_data; // XOR
            5'b00011: alu_out = rs1_data | rs2_data; // OR
            5'b00100: alu_out = rs1_data & rs2_data; // AND

            // Shift operations
            5'b00101: alu_out = rs1_data << rs2_data[4:0]; // SLL
            5'b00110: alu_out = rs1_data >> rs2_data[4:0]; // SRL
            5'b00111: alu_out = $signed(rs1_data) >>> rs2_data[4:0]; // SRA

            // Comparison operations
            5'b01000: begin // SLT - signed
                alu_out = ($signed(rs1_data) < $signed(rs2_data))
                          ? {{(DATA_WIDTH-1){1'b0}}, 1'b1}
                          : '0;
            end

            5'b01001: begin // SLTU - unsigned
                alu_out = (rs1_data < rs2_data)
                          ? {{(DATA_WIDTH-1){1'b0}}, 1'b1}
                          : '0;
            end

            // Branch comparisons
            5'b01010: zero = (rs1_data == rs2_data); // BEQ
            5'b01011: zero = (rs1_data != rs2_data); // BNE
            5'b01100: zero = ($signed(rs1_data) < $signed(rs2_data));  // BLT
            5'b01101: zero = ($signed(rs1_data) >= $signed(rs2_data)); // BGE
            5'b01110: zero = (rs1_data < rs2_data);  // BLTU
            5'b01111: zero = (rs1_data >= rs2_data); // BGEU

            // Unused codes
            default: begin
                alu_out = '0;
                zero    = 1'b0;
            end

        endcase
    end

endmodule
