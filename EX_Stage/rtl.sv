
module ex_stage (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm_out,
    input  logic [31:0] address,
    input  logic        branch,
    input  logic        alu_src,
    input  logic        fn7_5,
    input  logic        mux_inp,
    input  logic [2:0]  fn3,
    input  logic [6:0]  imm11_5,
    input  logic [2:0]  aluop,
    input  logic [6:0]  opcode,
    output logic        and_out_ex,
    output logic [31:0] alu_out,
    output logic [31:0] pc_ex_out
);

    logic [4:0]  alu_control_code;
    logic [31:0] alu_operand_b;
    logic        zero;
    logic [31:0] pc_signed_offset;

    // Select ALU operand B
    assign alu_operand_b = alu_src ? imm_out : rs2_data;

    // Generate the 5-bit ALU control code
    alu_control u_alu_control (
        .alu_op     (aluop),
        .fn3        (fn3),
        .imm11_5    (imm11_5),
        .fn7_5      (fn7_5),
        .control_out(alu_control_code)
    );

    // Perform arithmetic, logic, and branch comparisons
    alu #(.DATA_WIDTH(32)) u_alu (
        .alu_control(alu_control_code),
        .rs1_data   (rs1_data),
        .rs2_data   (alu_operand_b),
        .alu_out    (alu_out),
        .zero       (zero)
    );

    // Calculate the branch or jump target
    assign pc_signed_offset = address + imm_out;

    // JALR target is calculated by the ALU and aligned to 2 bytes
    always_comb begin
        if (mux_inp)
            pc_ex_out = {alu_out[31:1], 1'b0};
        else
            pc_ex_out = pc_signed_offset;
    end

    // Branch or jump taken
    always_comb begin
        and_out_ex = (branch && zero) ||
                     (opcode == 7'h6F) ||
                     (opcode == 7'h67);
    end

endmodule
