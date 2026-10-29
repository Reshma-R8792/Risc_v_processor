
module imm_generator(
    input  logic [11:0] imm_input,
    input  logic [2:0]  fn3,
    input  logic [6:0]  opcode,
    input  logic [19:0] imm_input_uj,
    output logic [31:0] imm_output
);

    always_comb begin
        case (opcode)

            // Branch: sign-extend immediate and shift left by 1
            7'b1100011: begin
                imm_output = $signed(imm_input) >>> 0;
                imm_output = {{19{imm_input[11]}}, imm_input, 1'b0};
            end

            // JAL: sign-extend the 20-bit immediate and shift left by 1
            7'b1101111: begin
                imm_output = {{11{imm_input_uj[19]}},
                              imm_input_uj, 1'b0};
            end

            // LUI and AUIPC: append 12 zero bits
            7'b0110111,
            7'b0010111: begin
                imm_output = {imm_input_uj, 12'b0};
            end

            // JALR: sign-extend the 12-bit immediate
            7'b1100111: begin
                imm_output = {{20{imm_input[11]}}, imm_input};
            end

            // I-type ALU shift instructions
            7'b0010011: begin
                if (fn3 == 3'b001 || fn3 == 3'b101)
                    imm_output = {27'b0, imm_input[4:0]};
                else
                    imm_output = {{20{imm_input[11]}}, imm_input};
            end

            // Load, store, R-type, and other instructions
            default: begin
                imm_output = {{20{imm_input[11]}}, imm_input};
            end

        endcase
    end

endmodule
