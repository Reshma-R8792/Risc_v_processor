
module single_cycle_riscv (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] mem_out,

    output logic [31:0] rs2_data,
    output logic [31:0] alu_out,
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,
    output logic [6:0]  opcode,
    output logic [31:0] address
);

    // Instruction Fetch signals
    logic [31:0] pc_new;
    logic        and_out;

    // Instruction Decode signals
    logic [31:0] rs1_data;
    logic [31:0] imm_out;
    logic [6:0]  imm11_5;
    logic        fn7_5;
    logic [2:0]  aluop;
    logic [1:0]  memtoreg;
    logic        branch;
    logic        alu_src;
    logic        mux_inp;

    // Execute signals
    logic        and_out_ex;
    logic [31:0] pc_ex_out;

    // Write-back signal
    logic [31:0] wb_data;

    // Instruction Fetch Stage
    if_stage u_if_stage (
        .clk             (clk),
        .reset           (reset),
        .stall            (stall),
        .and_out          (and_out),
        .pc_signed_offset (pc_ex_out),
        .address          (address),
        .pc_new           (pc_new)
    );

    // Instruction Decode Stage
    id_stage u_id_stage (
        .clk          (clk),
        .reset        (reset),
        .stall        (stall),
        .instruction  (instruction),
        .wb_data      (wb_data),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .imm_out      (imm_out),
        .opcode_out_d (opcode),
        .imm11_5      (imm11_5),
        .fn3_out_d    (fn3),
        .fn7_5        (fn7_5),
        .aluop        (aluop),
        .memtoreg     (memtoreg),
        .branch       (branch),
        .mem_write    (mem_write),
        .mem_read     (mem_read),
        .alu_src      (alu_src),
        .mux_inp      (mux_inp)
    );

    // Execute Stage
    ex_stage u_ex_stage (
        .rs1_data    (rs1_data),
        .rs2_data    (rs2_data),
        .imm_out     (imm_out),
        .address     (address),
        .branch      (branch),
        .alu_src     (alu_src),
        .fn7_5       (fn7_5),
        .mux_inp     (mux_inp),
        .fn3         (fn3),
        .imm11_5     (imm11_5),
        .aluop       (aluop),
        .opcode      (opcode),
        .and_out_ex  (and_out_ex),
        .alu_out     (alu_out),
        .pc_ex_out   (pc_ex_out)
    );

    // Feed branch/jump decision back to Instruction Fetch
    assign and_out = and_out_ex;

    // Write-back Stage
    wb_stage u_wb_stage (
        .mem_out         (mem_out),
        .alu_out         (alu_out),
        .return_addr     (pc_new),
        .imm_out         (imm_out),
        .pc_signed_offset(pc_ex_out),
        .memtoreg        (memtoreg),
        .opcode_out_d    (opcode),
        .wb_data         (wb_data)
    );

endmodule
