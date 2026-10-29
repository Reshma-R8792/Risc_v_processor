
module if_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic        and_out,
    input  logic [31:0] pc_signed_offset,
    output logic [31:0] address,
    output logic [31:0] pc_new
);

    logic [31:0] pc;

    // Calculate the next sequential PC
    assign pc_new = pc + 32'd4;

    // Select the next PC: branch/jump target or PC + 4
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h8000_0000;
        else if (!stall) begin
            if (and_out)
                pc <= pc_signed_offset;
            else
                pc <= pc + 32'd4;
        end
    end

    // Current instruction address
    assign address = pc;

endmodule
