`timescale 1ns/10ps
module IOTDF( clk, rst, in_en, iot_in, fn_sel, busy, valid, iot_out);
input          clk;
input          rst;
input          in_en;
input  [7:0]   iot_in;
input  [2:0]   fn_sel;
output         busy;
output         valid;
output [127:0] iot_out;

localparam S_IDLE = 3'd0;
localparam S_F1  = 3'd1;
localparam S_F2  = 3'd2;
localparam S_F3  = 3'd3;
localparam S_F4  = 3'd4;

reg [2:0] state, next_state;
reg busy_r;
reg valid_r;
reg [127:0] iot_out_r;
reg [127:0] iot_data_r, iot_data_w, iot_idata_r, iot_idata_w;

assign busy = busy_r;
assign valid = valid_r;
assign iot_out = iot_out_r;

integer i;

//F1 F2
reg [3:0] f1_counter_r, f1_counter_w;
reg f1_state_r, f1_state_w;
wire [63:0] main_key = ((state == S_F1)||(state == S_F2)) ? iot_idata_r[127:64] : 0;
wire [55:0] cipher_key;
wire [55:0] cipher_key_shifted [1:16];
wire [47:0] k [1:16];
reg [47:0] K;

PC1 u_PC1 (.i(main_key), .o(cipher_key)); //cipher key
CSL1 u_CSL1_1 (.i(cipher_key[55:28]), .o(cipher_key_shifted[1][55:28]));
CSL1 l_CSL1_1 (.i(cipher_key[27:0]), .o(cipher_key_shifted[1][27:0]));
PC2 u_PC2_1 (.i(cipher_key_shifted[1]), .o(k[1])); //K1
CSL1 u_CSL1_2 (.i(cipher_key_shifted[1][55:28]), .o(cipher_key_shifted[2][55:28]));
CSL1 l_CSL1_2 (.i(cipher_key_shifted[1][27:0]), .o(cipher_key_shifted[2][27:0]));
PC2 u_PC2_2 (.i(cipher_key_shifted[2]), .o(k[2])); //K2
CSL2 u_CSL2_3 (.i(cipher_key_shifted[2][55:28]), .o(cipher_key_shifted[3][55:28]));
CSL2 l_CSL2_3 (.i(cipher_key_shifted[2][27:0]), .o(cipher_key_shifted[3][27:0]));
PC2 u_PC2_3 (.i(cipher_key_shifted[3]), .o(k[3])); //K3
CSL2 u_CSL2_4 (.i(cipher_key_shifted[3][55:28]), .o(cipher_key_shifted[4][55:28]));
CSL2 l_CSL2_4 (.i(cipher_key_shifted[3][27:0]), .o(cipher_key_shifted[4][27:0]));
PC2 u_PC2_4 (.i(cipher_key_shifted[4]), .o(k[4])); //K4
CSL2 u_CSL2_5 (.i(cipher_key_shifted[4][55:28]), .o(cipher_key_shifted[5][55:28]));
CSL2 l_CSL2_5 (.i(cipher_key_shifted[4][27:0]), .o(cipher_key_shifted[5][27:0]));
PC2 u_PC2_5 (.i(cipher_key_shifted[5]), .o(k[5])); //K5
CSL2 u_CSL2_6 (.i(cipher_key_shifted[5][55:28]), .o(cipher_key_shifted[6][55:28]));
CSL2 l_CSL2_6 (.i(cipher_key_shifted[5][27:0]), .o(cipher_key_shifted[6][27:0]));
PC2 u_PC2_6 (.i(cipher_key_shifted[6]), .o(k[6])); //K6
CSL2 u_CSL2_7 (.i(cipher_key_shifted[6][55:28]), .o(cipher_key_shifted[7][55:28]));
CSL2 l_CSL2_7 (.i(cipher_key_shifted[6][27:0]), .o(cipher_key_shifted[7][27:0]));
PC2 u_PC2_7 (.i(cipher_key_shifted[7]), .o(k[7])); //K7
CSL2 u_CSL2_8 (.i(cipher_key_shifted[7][55:28]), .o(cipher_key_shifted[8][55:28]));
CSL2 l_CSL2_8 (.i(cipher_key_shifted[7][27:0]), .o(cipher_key_shifted[8][27:0]));
PC2 u_PC2_8 (.i(cipher_key_shifted[8]), .o(k[8])); //K8
CSL1 u_CSL1_9 (.i(cipher_key_shifted[8][55:28]), .o(cipher_key_shifted[9][55:28]));
CSL1 l_CSL1_9 (.i(cipher_key_shifted[8][27:0]), .o(cipher_key_shifted[9][27:0]));
PC2 u_PC2_9 (.i(cipher_key_shifted[9]), .o(k[9])); //K9
CSL2 u_CSL2_10 (.i(cipher_key_shifted[9][55:28]), .o(cipher_key_shifted[10][55:28]));
CSL2 l_CSL2_10 (.i(cipher_key_shifted[9][27:0]), .o(cipher_key_shifted[10][27:0]));
PC2 u_PC2_10 (.i(cipher_key_shifted[10]), .o(k[10])); //K10
CSL2 u_CSL2_11 (.i(cipher_key_shifted[10][55:28]), .o(cipher_key_shifted[11][55:28]));
CSL2 l_CSL2_11 (.i(cipher_key_shifted[10][27:0]), .o(cipher_key_shifted[11][27:0]));
PC2 u_PC2_11 (.i(cipher_key_shifted[11]), .o(k[11])); //K11
CSL2 u_CSL2_12 (.i(cipher_key_shifted[11][55:28]), .o(cipher_key_shifted[12][55:28]));
CSL2 l_CSL2_12 (.i(cipher_key_shifted[11][27:0]), .o(cipher_key_shifted[12][27:0]));
PC2 u_PC2_12 (.i(cipher_key_shifted[12]), .o(k[12])); //K12
CSL2 u_CSL2_13 (.i(cipher_key_shifted[12][55:28]), .o(cipher_key_shifted[13][55:28]));
CSL2 l_CSL2_13 (.i(cipher_key_shifted[12][27:0]), .o(cipher_key_shifted[13][27:0]));
PC2 u_PC2_13 (.i(cipher_key_shifted[13]), .o(k[13])); //K13
CSL2 u_CSL2_14 (.i(cipher_key_shifted[13][55:28]), .o(cipher_key_shifted[14][55:28]));
CSL2 l_CSL2_14 (.i(cipher_key_shifted[13][27:0]), .o(cipher_key_shifted[14][27:0]));
PC2 u_PC2_14 (.i(cipher_key_shifted[14]), .o(k[14])); //K14
CSL2 u_CSL2_15 (.i(cipher_key_shifted[14][55:28]), .o(cipher_key_shifted[15][55:28]));
CSL2 l_CSL2_15 (.i(cipher_key_shifted[14][27:0]), .o(cipher_key_shifted[15][27:0]));
PC2 u_PC2_15 (.i(cipher_key_shifted[15]), .o(k[15])); //K15
CSL1 u_CSL1_16 (.i(cipher_key_shifted[15][55:28]), .o(cipher_key_shifted[16][55:28]));
CSL1 l_CSL1_16 (.i(cipher_key_shifted[15][27:0]), .o(cipher_key_shifted[16][27:0]));
PC2 u_PC2_16 (.i(cipher_key_shifted[16]), .o(k[16])); //K16


//Select K
always @(*) begin
    case(state) 
        S_F1: begin
            case(f1_counter_r)
                4'd0: K = k[1];
                4'd1: K = k[2];
                4'd2: K = k[3];
                4'd3: K = k[4];
                4'd4: K = k[5];
                4'd5: K = k[6];
                4'd6: K = k[7];
                4'd7: K = k[8];
                4'd8: K = k[9];
                4'd9: K = k[10];
                4'd10: K = k[11];
                4'd11: K = k[12];
                4'd12: K = k[13];
                4'd13: K = k[14];
                4'd14: K = k[15];
                4'd15: K = k[16];
            endcase
        end 
        S_F2: begin
            case(f1_counter_r)
                4'd0: K = k[16];
                4'd1: K = k[15];
                4'd2: K = k[14];
                4'd3: K = k[13];
                4'd4: K = k[12];
                4'd5: K = k[11];
                4'd6: K = k[10];
                4'd7: K = k[9];
                4'd8: K = k[8];
                4'd9: K = k[7];
                4'd10: K = k[6];
                4'd11: K = k[5];
                4'd12: K = k[4];
                4'd13: K = k[3];
                4'd14: K = k[2];
                4'd15: K = k[1];
            endcase
        end
        default: K = 48'd0;
    endcase
end

wire [63:0] plaintext = ((state == S_F1)||(state == S_F2)) ? iot_idata_r[63:0] : 64'd0;
wire [63:0] plaintext_ip;
IP u_IP(.i(plaintext), .o(plaintext_ip));
wire [31:0] L, R, L_XOR, R_F;
wire [31:0] R_w;
wire [63:0] ciphertext;

assign R_w = iot_idata_r[63:32];
assign L = ((state == S_F1)||(state == S_F2)) ? ((f1_counter_r == 4'd0) ? plaintext_ip[63:32] : iot_idata_r[31:0]) : 32'd0;
assign R = ((state == S_F1)||(state == S_F2)) ? ((f1_counter_r == 4'd0) ? plaintext_ip[31:0] : iot_idata_r[63:32]) : 32'd0;
F u_F (.R(R), .K(K), .o(R_F));
assign L_XOR = L ^ R_F;
FP u_FP (.i({L_XOR, R_w}), .o(ciphertext));

// F3
reg [2:0] crc_w, crc_r, crc[0:6];
wire crc_feedback[0:7];

assign crc_feedback[0] = iot_idata_r[127 - f1_counter_r*8] ^ crc_r[2];
assign crc_feedback[1] = iot_idata_r[126 - f1_counter_r*8] ^ crc[0][2];
assign crc_feedback[2] = iot_idata_r[125 - f1_counter_r*8] ^ crc[1][2];
assign crc_feedback[3] = iot_idata_r[124 - f1_counter_r*8] ^ crc[2][2];
assign crc_feedback[4] = iot_idata_r[123 - f1_counter_r*8] ^ crc[3][2];
assign crc_feedback[5] = iot_idata_r[122 - f1_counter_r*8] ^ crc[4][2];
assign crc_feedback[6] = iot_idata_r[121 - f1_counter_r*8] ^ crc[5][2];
assign crc_feedback[7] = iot_idata_r[120 - f1_counter_r*8] ^ crc[6][2];

always @(*) begin
    crc_w = crc_r;
    for(i = 0; i < 7; i = i + 1) begin
        crc[i] = 3'b000;
    end
    if(state == S_F3) begin
        crc[0] = {crc_r[1:0], 1'b0} ^ ((crc_feedback[0]) ? 3'b101 : 3'b000);
        crc[1] = {crc[0][1:0], 1'b0} ^ ((crc_feedback[1]) ? 3'b101 : 3'b000);
        crc[2] = {crc[1][1:0], 1'b0} ^ ((crc_feedback[2]) ? 3'b101 : 3'b000);
        crc[3] = {crc[2][1:0], 1'b0} ^ ((crc_feedback[3]) ? 3'b101 : 3'b000);
        crc[4] = {crc[3][1:0], 1'b0} ^ ((crc_feedback[4]) ? 3'b101 : 3'b000);
        crc[5] = {crc[4][1:0], 1'b0} ^ ((crc_feedback[5]) ? 3'b101 : 3'b000);
        crc[6] = {crc[5][1:0], 1'b0} ^ ((crc_feedback[6]) ? 3'b101 : 3'b000);
        crc_w = {crc[6][1:0], 1'b0} ^ ((crc_feedback[7]) ? 3'b101 : 3'b000);
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) crc_r <= 3'd0;
    else if(f1_counter_r == 4'd15) begin
        crc_r <= 3'd0;
    end else begin
        crc_r <= crc_w;
    end
end

//F4
reg [15:0] comparator_in [0:7], comparator_out [0:7];

always @(*) begin
    for(i = 0; i < 8; i = i + 1) begin
        comparator_out[i] = (comparator_in[i][15:8] < comparator_in[i][7:0]) ? {comparator_in[i][7:0], comparator_in[i][15:8]} : comparator_in[i];
    end
end

always @(*) begin
    for(i = 0; i < 8; i = i + 1) begin
        comparator_in[i] = 0;
    end
    if(state == S_F4) begin
        if(f1_counter_r[0]) begin
            for(i = 0; i < 7; i = i + 1) begin
                comparator_in[i] = iot_idata_r[16*i+8 +: 16];
            end
        end else begin
            for(i = 0; i < 8; i = i + 1) begin
                comparator_in[i] = iot_idata_r[16*i +: 16];
            end
        end
    end
end

//---------- FSM ----------//
always @(*) begin
    case(state)
        S_IDLE: begin
            next_state = fn_sel;
        end
        default: next_state = state;
    endcase
end 

always @(posedge clk or posedge rst) begin
    if(rst) state <= S_IDLE;
    else state <= next_state;
end
//---------- FSM ----------//

// Busy
always @(*) begin
    case(state)
        S_IDLE: busy_r = 1'b0;
        S_F1: busy_r = 1'b0;
        S_F2: busy_r = 1'b0;
        S_F3: busy_r = 1'b0;
        S_F4: busy_r = 1'b0;
        default: busy_r = 1'b1;
    endcase
end

//Valid
always @(posedge clk or posedge rst) begin
    if(rst) valid_r <= 1'b0;
    else begin
        case(state)
            S_F1: valid_r <= ((f1_counter_r == 4'd15) && (f1_state_r)) ? 1'b1 : 1'b0;
            S_F2: valid_r <= ((f1_counter_r == 4'd15) && (f1_state_r)) ? 1'b1 : 1'b0;
            S_F3: valid_r <= ((f1_counter_r == 4'd15) && (f1_state_r)) ? 1'b1 : 1'b0;
            S_F4: valid_r <= ((f1_counter_r == 4'd15) && (f1_state_r)) ? 1'b1 : 1'b0;
            default: valid_r <= 1'b0;
        endcase
    end
end

// Output
always @(posedge clk or posedge rst) begin
    if(rst) iot_out_r <= 128'd0;
    else begin
        case(state)
            S_F1: begin
                iot_out_r <= {iot_idata_r[127:64], ciphertext};
            end
            S_F2: begin
                iot_out_r <= {iot_idata_r[127:64], ciphertext};
            end
            S_F3: begin
                iot_out_r <= {125'd0, crc_w};
            end
            S_F4: begin
                iot_out_r <= iot_idata_w;
            end
            default: iot_out_r <= 0;
        endcase
    end
end

//iot_data
always @(*)begin
    iot_data_w = iot_data_r;
    iot_data_w[f1_counter_r*8 +: 8] = iot_in;
end

always @(posedge clk or posedge rst) begin
    if(rst) iot_data_r <= 128'd0;
    else begin
        iot_data_r <= iot_data_w;
    end
end

always @(*) begin
    iot_idata_w = iot_idata_r;
    if(state == S_F4) begin
        if(f1_counter_r[0]) begin
            for(i = 0; i < 7; i = i + 1) begin
                iot_idata_w[i*16+8 +: 16] = comparator_out[i];
            end
        end else begin
            for(i = 0; i < 8; i = i + 1) begin
                iot_idata_w[i*16 +: 16] = comparator_out[i];
            end
        end
    end else if((state == S_F1) || (state == S_F2)) begin
        if(f1_counter_r == 4'd15) begin
                iot_idata_w[63:32] = R_w;
                iot_idata_w[31:0] = L_XOR;
            end else begin
                iot_idata_w[63:32] = L_XOR;
                iot_idata_w[31:0] = R;
            end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) iot_idata_r <= 128'd0;
    else begin
        case(state)
            S_F1: begin
                iot_idata_r <= (f1_counter_r == 4'd15) ? iot_data_w : iot_idata_w; 
            end
            S_F2: begin
                iot_idata_r <= (f1_counter_r == 4'd15) ? iot_data_w : iot_idata_w; 
            end
            S_F3: begin
                iot_idata_r <= (f1_counter_r == 4'd15) ? iot_data_w : iot_idata_w; 
            end
            S_F4: begin
                iot_idata_r <= (f1_counter_r == 4'd15) ? iot_data_w : iot_idata_w; 
            end
            default: iot_idata_r <= iot_idata_w;
        endcase
    end
end

//F1
always @(*) begin
    f1_counter_w = (f1_counter_r == 4'd15) ? 4'd0 : f1_counter_r + 4'd1;
    f1_state_w = (f1_counter_r == 4'd15) ? 1'b1 : f1_state_r;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        f1_counter_r <= 4'd0;
        f1_state_r <= 1'b0;
    end else if(state != S_IDLE) begin
        f1_counter_r <= f1_counter_w;
        f1_state_r <= f1_state_w;
    end
end


endmodule

module F(
    input  [31:0] R,
    input  [47:0] K,
    output [31:0] o
);

wire [47:0] R_exp;
Expansion u_Expansion(.i(R), .o(R_exp));

wire [47:0] R_xor_K = R_exp ^ K;
wire [31:0] S_o;

S1 u_S1 (.i(R_xor_K[47:42]), .o(S_o[31:28]));
S2 u_S2 (.i(R_xor_K[41:36]), .o(S_o[27:24]));
S3 u_S3 (.i(R_xor_K[35:30]), .o(S_o[23:20]));
S4 u_S4 (.i(R_xor_K[29:24]), .o(S_o[19:16]));
S5 u_S5 (.i(R_xor_K[23:18]), .o(S_o[15:12]));
S6 u_S6 (.i(R_xor_K[17:12]), .o(S_o[11:8]));
S7 u_S7 (.i(R_xor_K[11:6]), .o(S_o[7:4]));
S8 u_S8 (.i(R_xor_K[5:0]), .o(S_o[3:0]));

P u_P (.i(S_o), .o(o));

endmodule

module PC1(
    input  [63:0] i,
    output [55:0] o
);

assign o = {
    i[7], i[15], i[23], i[31], i[39], i[47], i[55], i[63],
    i[6], i[14], i[22], i[30], i[38], i[46], i[54], i[62], 
    i[5], i[13], i[21], i[29], i[37], i[45], i[53], i[61],
    i[4], i[12], i[20], i[28],
    i[1], i[9], i[17], i[25], i[33], i[41], i[49], i[57],
    i[2], i[10], i[18], i[26], i[34], i[42], i[50], i[58],
    i[3], i[11], i[19], i[27], i[35], i[43], i[51], i[59],
    i[36], i[44], i[52], i[60]
};

endmodule

module PC2(
    input  [55:0] i,
    output [47:0] o
);

assign o = {
    i[42], i[39], i[45], i[32], i[55], i[51], i[53], i[28],
    i[41], i[50], i[35], i[46], i[33], i[37], i[44], i[52],
    i[30], i[48], i[40], i[49], i[29], i[36], i[43], i[54],
    i[15], i[4], i[25], i[19], i[9], i[1], i[26], i[16],
    i[5], i[11], i[23], i[8], i[12], i[7], i[17], i[0],
    i[22], i[3], i[10], i[14], i[6], i[20], i[27], i[24]
};

endmodule

module IP(
    input  [63:0] i,
    output [63:0] o
);

assign o = {
    i[6], i[14], i[22], i[30], i[38], i[46], i[54], i[62],
    i[4], i[12], i[20], i[28], i[36], i[44], i[52], i[60],
    i[2], i[10], i[18], i[26], i[34], i[42], i[50], i[58],
    i[0], i[8], i[16], i[24], i[32], i[40], i[48], i[56],
    i[7], i[15], i[23], i[31], i[39], i[47], i[55], i[63],
    i[5], i[13], i[21], i[29], i[37], i[45], i[53], i[61],
    i[3], i[11], i[19], i[27], i[35], i[43], i[51], i[59],
    i[1], i[9], i[17], i[25], i[33], i[41], i[49], i[57]
};

endmodule

module FP(
    input  [63:0] i,
    output [63:0] o
);

assign o = {
    i[24], i[56], i[16], i[48], i[8], i[40], i[0], i[32],
    i[25], i[57], i[17], i[49], i[9], i[41], i[1], i[33],
    i[26], i[58], i[18], i[50], i[10], i[42], i[2], i[34],
    i[27], i[59], i[19], i[51], i[11], i[43], i[3], i[35],
    i[28], i[60], i[20], i[52], i[12], i[44], i[4], i[36],
    i[29], i[61], i[21], i[53], i[13], i[45], i[5], i[37],
    i[30], i[62], i[22], i[54], i[14], i[46], i[6], i[38],
    i[31], i[63], i[23], i[55], i[15], i[47], i[7], i[39]
};

endmodule

module P(
    input  [31:0] i,
    output [31:0] o
);

assign o = {
    i[16], i[25], i[12], i[11], i[3], i[20], i[4], i[15],
    i[31], i[17], i[9], i[6], i[27], i[14], i[1], i[22],
    i[30], i[24], i[8], i[18], i[0], i[5], i[29], i[23],
    i[13], i[19], i[2], i[26], i[10], i[21], i[28], i[7]
};

endmodule

module Expansion(
    input  [31:0] i,
    output [47:0] o
);

assign o = {
    i[0], i[31], i[30], i[29], i[28], i[27],
    i[28], i[27], i[26], i[25], i[24], i[23],
    i[24], i[23], i[22], i[21], i[20], i[19],
    i[20], i[19], i[18], i[17], i[16], i[15],
    i[16], i[15], i[14], i[13], i[12], i[11],
    i[12], i[11], i[10], i[9], i[8], i[7],
    i[8], i[7], i[6], i[5], i[4], i[3],
    i[4], i[3], i[2], i[1], i[0], i[31]
};

endmodule

module CSL1(
    input [27:0] i,
    output [27:0] o
);

assign o = {i[26:0], i[27]};

endmodule

module CSL2(
    input [27:0] i,
    output [27:0] o
);

assign o = {i[25:0], i[27:26]};

endmodule

module S1(
    input [5:0] i,
    output [3:0] o
);

reg [3:0] o_r;
assign o = o_r;

always @(*) begin
    case(i)
        6'b000000: o_r = 4'd14;
        6'b000010: o_r = 4'd4;
        6'b000100: o_r = 4'd13;
        6'b000110: o_r = 4'd1;
        6'b001000: o_r = 4'd2;
        6'b001010: o_r = 4'd15;
        6'b001100: o_r = 4'd11;
        6'b001110: o_r = 4'd8;
        6'b010000: o_r = 4'd3;
        6'b010010: o_r = 4'd10;
        6'b010100: o_r = 4'd6;
        6'b010110: o_r = 4'd12;
        6'b011000: o_r = 4'd5;
        6'b011010: o_r = 4'd9;
        6'b011100: o_r = 4'd0;
        6'b011110: o_r = 4'd7;
        6'b000001: o_r = 4'd0;
        6'b000011: o_r = 4'd15;
        6'b000101: o_r = 4'd7;
        6'b000111: o_r = 4'd4;
        6'b001001: o_r = 4'd14;
        6'b001011: o_r = 4'd2;
        6'b001101: o_r = 4'd13;
        6'b001111: o_r = 4'd1;
        6'b010001: o_r = 4'd10;
        6'b010011: o_r = 4'd6;
        6'b010101: o_r = 4'd12;
        6'b010111: o_r = 4'd11;
        6'b011001: o_r = 4'd9;
        6'b011011: o_r = 4'd5;
        6'b011101: o_r = 4'd3;
        6'b011111: o_r = 4'd8;
        6'b100000: o_r = 4'd4;
        6'b100010: o_r = 4'd1;
        6'b100100: o_r = 4'd14;
        6'b100110: o_r = 4'd8;
        6'b101000: o_r = 4'd13;
        6'b101010: o_r = 4'd6;
        6'b101100: o_r = 4'd2;
        6'b101110: o_r = 4'd11;
        6'b110000: o_r = 4'd15;
        6'b110010: o_r = 4'd12;
        6'b110100: o_r = 4'd9;
        6'b110110: o_r = 4'd7;
        6'b111000: o_r = 4'd3;
        6'b111010: o_r = 4'd10;
        6'b111100: o_r = 4'd5;
        6'b111110: o_r = 4'd0;
        6'b100001: o_r = 4'd15;
        6'b100011: o_r = 4'd12;
        6'b100101: o_r = 4'd8;
        6'b100111: o_r = 4'd2;
        6'b101001: o_r = 4'd4;
        6'b101011: o_r = 4'd9;
        6'b101101: o_r = 4'd1;
        6'b101111: o_r = 4'd7;
        6'b110001: o_r = 4'd5;
        6'b110011: o_r = 4'd11;
        6'b110101: o_r = 4'd3;
        6'b110111: o_r = 4'd14;
        6'b111001: o_r = 4'd10;
        6'b111011: o_r = 4'd0;
        6'b111101: o_r = 4'd6;
        6'b111111: o_r = 4'd13;
    endcase
end

endmodule

module S2(
    input [5:0] i,
    output [3:0] o
);

reg [3:0] o_r;
assign o = o_r;

always @(*) begin
    case(i)
        6'b000000: o_r = 4'd15;
        6'b000010: o_r = 4'd1;
        6'b000100: o_r = 4'd8;
        6'b000110: o_r = 4'd14;
        6'b001000: o_r = 4'd6;
        6'b001010: o_r = 4'd11;
        6'b001100: o_r = 4'd3;
        6'b001110: o_r = 4'd4;
        6'b010000: o_r = 4'd9;
        6'b010010: o_r = 4'd7;
        6'b010100: o_r = 4'd2;
        6'b010110: o_r = 4'd13;
        6'b011000: o_r = 4'd12;
        6'b011010: o_r = 4'd0;
        6'b011100: o_r = 4'd5;
        6'b011110: o_r = 4'd10;
        6'b000001: o_r = 4'd3;
        6'b000011: o_r = 4'd13;
        6'b000101: o_r = 4'd4;
        6'b000111: o_r = 4'd7;
        6'b001001: o_r = 4'd15;
        6'b001011: o_r = 4'd2;
        6'b001101: o_r = 4'd8;
        6'b001111: o_r = 4'd14;
        6'b010001: o_r = 4'd12;
        6'b010011: o_r = 4'd0;
        6'b010101: o_r = 4'd1;
        6'b010111: o_r = 4'd10;
        6'b011001: o_r = 4'd6;
        6'b011011: o_r = 4'd9;
        6'b011101: o_r = 4'd11;
        6'b011111: o_r = 4'd5;
        6'b100000: o_r = 4'd0;
        6'b100010: o_r = 4'd14;
        6'b100100: o_r = 4'd7;
        6'b100110: o_r = 4'd11;
        6'b101000: o_r = 4'd10;
        6'b101010: o_r = 4'd4;
        6'b101100: o_r = 4'd13;
        6'b101110: o_r = 4'd1;
        6'b110000: o_r = 4'd5;
        6'b110010: o_r = 4'd8;
        6'b110100: o_r = 4'd12;
        6'b110110: o_r = 4'd6;
        6'b111000: o_r = 4'd9;
        6'b111010: o_r = 4'd3;
        6'b111100: o_r = 4'd2;
        6'b111110: o_r = 4'd15;
        6'b100001: o_r = 4'd13;
        6'b100011: o_r = 4'd8;
        6'b100101: o_r = 4'd10;
        6'b100111: o_r = 4'd1;
        6'b101001: o_r = 4'd3;
        6'b101011: o_r = 4'd15;
        6'b101101: o_r = 4'd4;
        6'b101111: o_r = 4'd2;
        6'b110001: o_r = 4'd11;
        6'b110011: o_r = 4'd6;
        6'b110101: o_r = 4'd7;
        6'b110111: o_r = 4'd12;
        6'b111001: o_r = 4'd0;
        6'b111011: o_r = 4'd5;
        6'b111101: o_r = 4'd14;
        6'b111111: o_r = 4'd9;
    endcase
end

endmodule

module S3(
    input [5:0] i,
    output [3:0] o
);

reg [3:0] o_r;
assign o = o_r;

always @(*) begin
    case(i)
        6'b000000: o_r = 4'd10;
        6'b000010: o_r = 4'd0;
        6'b000100: o_r = 4'd9;
        6'b000110: o_r = 4'd14;
        6'b001000: o_r = 4'd6;
        6'b001010: o_r = 4'd3;
        6'b001100: o_r = 4'd15;
        6'b001110: o_r = 4'd5;
        6'b010000: o_r = 4'd1;
        6'b010010: o_r = 4'd13;
        6'b010100: o_r = 4'd12;
        6'b010110: o_r = 4'd7;
        6'b011000: o_r = 4'd11;
        6'b011010: o_r = 4'd4;
        6'b011100: o_r = 4'd2;
        6'b011110: o_r = 4'd8;
        6'b000001: o_r = 4'd13;
        6'b000011: o_r = 4'd7;
        6'b000101: o_r = 4'd0;
        6'b000111: o_r = 4'd9;
        6'b001001: o_r = 4'd3;
        6'b001011: o_r = 4'd4;
        6'b001101: o_r = 4'd6;
        6'b001111: o_r = 4'd10;
        6'b010001: o_r = 4'd2;
        6'b010011: o_r = 4'd8;
        6'b010101: o_r = 4'd5;
        6'b010111: o_r = 4'd14;
        6'b011001: o_r = 4'd12;
        6'b011011: o_r = 4'd11;
        6'b011101: o_r = 4'd15;
        6'b011111: o_r = 4'd1;
        6'b100000: o_r = 4'd13;
        6'b100010: o_r = 4'd6;
        6'b100100: o_r = 4'd4;
        6'b100110: o_r = 4'd9;
        6'b101000: o_r = 4'd8;
        6'b101010: o_r = 4'd15;
        6'b101100: o_r = 4'd3;
        6'b101110: o_r = 4'd0;
        6'b110000: o_r = 4'd11;
        6'b110010: o_r = 4'd1;
        6'b110100: o_r = 4'd2;
        6'b110110: o_r = 4'd12;
        6'b111000: o_r = 4'd5;
        6'b111010: o_r = 4'd10;
        6'b111100: o_r = 4'd14;
        6'b111110: o_r = 4'd7;
        6'b100001: o_r = 4'd1;
        6'b100011: o_r = 4'd10;
        6'b100101: o_r = 4'd13;
        6'b100111: o_r = 4'd0;
        6'b101001: o_r = 4'd6;
        6'b101011: o_r = 4'd9;
        6'b101101: o_r = 4'd8;
        6'b101111: o_r = 4'd7;
        6'b110001: o_r = 4'd4;
        6'b110011: o_r = 4'd15;
        6'b110101: o_r = 4'd14;
        6'b110111: o_r = 4'd3;
        6'b111001: o_r = 4'd11;
        6'b111011: o_r = 4'd5;
        6'b111101: o_r = 4'd2;
        6'b111111: o_r = 4'd12;
    endcase
end

endmodule

module S4(
    input [5:0] i,
    output [3:0] o
);

reg [3:0] o_r;
assign o = o_r;

always @(*) begin
    case(i)
        6'b000000: o_r = 4'd7;
        6'b000010: o_r = 4'd13;
        6'b000100: o_r = 4'd14;
        6'b000110: o_r = 4'd3;
        6'b001000: o_r = 4'd0;
        6'b001010: o_r = 4'd6;
        6'b001100: o_r = 4'd9;
        6'b001110: o_r = 4'd10;
        6'b010000: o_r = 4'd1;
        6'b010010: o_r = 4'd2;
        6'b010100: o_r = 4'd8;
        6'b010110: o_r = 4'd5;
        6'b011000: o_r = 4'd11;
        6'b011010: o_r = 4'd12;
        6'b011100: o_r = 4'd4;
        6'b011110: o_r = 4'd15;
        6'b000001: o_r = 4'd13;
        6'b000011: o_r = 4'd8;
        6'b000101: o_r = 4'd11;
        6'b000111: o_r = 4'd5;
        6'b001001: o_r = 4'd6;
        6'b001011: o_r = 4'd15;
        6'b001101: o_r = 4'd0;
        6'b001111: o_r = 4'd3;
        6'b010001: o_r = 4'd4;
        6'b010011: o_r = 4'd7;
        6'b010101: o_r = 4'd2;
        6'b010111: o_r = 4'd12;
        6'b011001: o_r = 4'd1;
        6'b011011: o_r = 4'd10;
        6'b011101: o_r = 4'd14;
        6'b011111: o_r = 4'd9;
        6'b100000: o_r = 4'd10;
        6'b100010: o_r = 4'd6;
        6'b100100: o_r = 4'd9;
        6'b100110: o_r = 4'd0;
        6'b101000: o_r = 4'd12;
        6'b101010: o_r = 4'd11;
        6'b101100: o_r = 4'd7;
        6'b101110: o_r = 4'd13;
        6'b110000: o_r = 4'd15;
        6'b110010: o_r = 4'd1;
        6'b110100: o_r = 4'd3;
        6'b110110: o_r = 4'd14;
        6'b111000: o_r = 4'd5;
        6'b111010: o_r = 4'd2;
        6'b111100: o_r = 4'd8;
        6'b111110: o_r = 4'd4;
        6'b100001: o_r = 4'd3;
        6'b100011: o_r = 4'd15;
        6'b100101: o_r = 4'd0;
        6'b100111: o_r = 4'd6;
        6'b101001: o_r = 4'd10;
        6'b101011: o_r = 4'd1;
        6'b101101: o_r = 4'd13;
        6'b101111: o_r = 4'd8;
        6'b110001: o_r = 4'd9;
        6'b110011: o_r = 4'd4;
        6'b110101: o_r = 4'd5;
        6'b110111: o_r = 4'd11;
        6'b111001: o_r = 4'd12;
        6'b111011: o_r = 4'd7;
        6'b111101: o_r = 4'd2;
        6'b111111: o_r = 4'd14;
    endcase
end

endmodule

module S5(
    input [5:0] i,
    output [3:0] o
);

reg [3:0] o_r;
assign o = o_r;

always @(*) begin
    case(i)
        6'b000000: o_r = 4'd2;
        6'b000010: o_r = 4'd12;
        6'b000100: o_r = 4'd4;
        6'b000110: o_r = 4'd1;
        6'b001000: o_r = 4'd7;
        6'b001010: o_r = 4'd10;
        6'b001100: o_r = 4'd11;
        6'b001110: o_r = 4'd6;
        6'b010000: o_r = 4'd8;
        6'b010010: o_r = 4'd5;
        6'b010100: o_r = 4'd3;
        6'b010110: o_r = 4'd15;
        6'b011000: o_r = 4'd13;
        6'b011010: o_r = 4'd0;
        6'b011100: o_r = 4'd14;
        6'b011110: o_r = 4'd9;
        6'b000001: o_r = 4'd14;
        6'b000011: o_r = 4'd11;
        6'b000101: o_r = 4'd2;
        6'b000111: o_r = 4'd12;
        6'b001001: o_r = 4'd4;
        6'b001011: o_r = 4'd7;
        6'b001101: o_r = 4'd13;
        6'b001111: o_r = 4'd1;
        6'b010001: o_r = 4'd5;
        6'b010011: o_r = 4'd0;
        6'b010101: o_r = 4'd15;
        6'b010111: o_r = 4'd10;
        6'b011001: o_r = 4'd3;
        6'b011011: o_r = 4'd9;
        6'b011101: o_r = 4'd8;
        6'b011111: o_r = 4'd6;
        6'b100000: o_r = 4'd4;
        6'b100010: o_r = 4'd2;
        6'b100100: o_r = 4'd1;
        6'b100110: o_r = 4'd11;
        6'b101000: o_r = 4'd10;
        6'b101010: o_r = 4'd13;
        6'b101100: o_r = 4'd7;
        6'b101110: o_r = 4'd8;
        6'b110000: o_r = 4'd15;
        6'b110010: o_r = 4'd9;
        6'b110100: o_r = 4'd12;
        6'b110110: o_r = 4'd5;
        6'b111000: o_r = 4'd6;
        6'b111010: o_r = 4'd3;
        6'b111100: o_r = 4'd0;
        6'b111110: o_r = 4'd14;
        6'b100001: o_r = 4'd11;
        6'b100011: o_r = 4'd8;
        6'b100101: o_r = 4'd12;
        6'b100111: o_r = 4'd7;
        6'b101001: o_r = 4'd1;
        6'b101011: o_r = 4'd14;
        6'b101101: o_r = 4'd2;
        6'b101111: o_r = 4'd13;
        6'b110001: o_r = 4'd6;
        6'b110011: o_r = 4'd15;
        6'b110101: o_r = 4'd0;
        6'b110111: o_r = 4'd9;
        6'b111001: o_r = 4'd10;
        6'b111011: o_r = 4'd4;
        6'b111101: o_r = 4'd5;
        6'b111111: o_r = 4'd3;
    endcase
end

endmodule

module S6(
    input [5:0] i,
    output [3:0] o
);

reg [3:0] o_r;
assign o = o_r;

always @(*) begin
    case(i)
        6'b000000: o_r = 4'd12;
        6'b000010: o_r = 4'd1;
        6'b000100: o_r = 4'd10;
        6'b000110: o_r = 4'd15;
        6'b001000: o_r = 4'd9;
        6'b001010: o_r = 4'd2;
        6'b001100: o_r = 4'd6;
        6'b001110: o_r = 4'd8;
        6'b010000: o_r = 4'd0;
        6'b010010: o_r = 4'd13;
        6'b010100: o_r = 4'd3;
        6'b010110: o_r = 4'd4;
        6'b011000: o_r = 4'd14;
        6'b011010: o_r = 4'd7;
        6'b011100: o_r = 4'd5;
        6'b011110: o_r = 4'd11;
        6'b000001: o_r = 4'd10;
        6'b000011: o_r = 4'd15;
        6'b000101: o_r = 4'd4;
        6'b000111: o_r = 4'd2;
        6'b001001: o_r = 4'd7;
        6'b001011: o_r = 4'd12;
        6'b001101: o_r = 4'd9;
        6'b001111: o_r = 4'd5;
        6'b010001: o_r = 4'd6;
        6'b010011: o_r = 4'd1;
        6'b010101: o_r = 4'd13;
        6'b010111: o_r = 4'd14;
        6'b011001: o_r = 4'd0;
        6'b011011: o_r = 4'd11;
        6'b011101: o_r = 4'd3;
        6'b011111: o_r = 4'd8;
        6'b100000: o_r = 4'd9;
        6'b100010: o_r = 4'd14;
        6'b100100: o_r = 4'd15;
        6'b100110: o_r = 4'd5;
        6'b101000: o_r = 4'd2;
        6'b101010: o_r = 4'd8;
        6'b101100: o_r = 4'd12;
        6'b101110: o_r = 4'd3;
        6'b110000: o_r = 4'd7;
        6'b110010: o_r = 4'd0;
        6'b110100: o_r = 4'd4;
        6'b110110: o_r = 4'd10;
        6'b111000: o_r = 4'd1;
        6'b111010: o_r = 4'd13;
        6'b111100: o_r = 4'd11;
        6'b111110: o_r = 4'd6;
        6'b100001: o_r = 4'd4;
        6'b100011: o_r = 4'd3;
        6'b100101: o_r = 4'd2;
        6'b100111: o_r = 4'd12;
        6'b101001: o_r = 4'd9;
        6'b101011: o_r = 4'd5;
        6'b101101: o_r = 4'd15;
        6'b101111: o_r = 4'd10;
        6'b110001: o_r = 4'd11;
        6'b110011: o_r = 4'd14;
        6'b110101: o_r = 4'd1;
        6'b110111: o_r = 4'd7;
        6'b111001: o_r = 4'd6;
        6'b111011: o_r = 4'd0;
        6'b111101: o_r = 4'd8;
        6'b111111: o_r = 4'd13;
    endcase
end

endmodule

module S7(
    input [5:0] i,
    output [3:0] o
);

reg [3:0] o_r;
assign o = o_r;

always @(*) begin
    case(i)
        6'b000000: o_r = 4'd4;
        6'b000010: o_r = 4'd11;
        6'b000100: o_r = 4'd2;
        6'b000110: o_r = 4'd14;
        6'b001000: o_r = 4'd15;
        6'b001010: o_r = 4'd0;
        6'b001100: o_r = 4'd8;
        6'b001110: o_r = 4'd13;
        6'b010000: o_r = 4'd3;
        6'b010010: o_r = 4'd12;
        6'b010100: o_r = 4'd9;
        6'b010110: o_r = 4'd7;
        6'b011000: o_r = 4'd5;
        6'b011010: o_r = 4'd10;
        6'b011100: o_r = 4'd6;
        6'b011110: o_r = 4'd1;
        6'b000001: o_r = 4'd13;
        6'b000011: o_r = 4'd0;
        6'b000101: o_r = 4'd11;
        6'b000111: o_r = 4'd7;
        6'b001001: o_r = 4'd4;
        6'b001011: o_r = 4'd9;
        6'b001101: o_r = 4'd1;
        6'b001111: o_r = 4'd10;
        6'b010001: o_r = 4'd14;
        6'b010011: o_r = 4'd3;
        6'b010101: o_r = 4'd5;
        6'b010111: o_r = 4'd12;
        6'b011001: o_r = 4'd2;
        6'b011011: o_r = 4'd15;
        6'b011101: o_r = 4'd8;
        6'b011111: o_r = 4'd6;
        6'b100000: o_r = 4'd1;
        6'b100010: o_r = 4'd4;
        6'b100100: o_r = 4'd11;
        6'b100110: o_r = 4'd13;
        6'b101000: o_r = 4'd12;
        6'b101010: o_r = 4'd3;
        6'b101100: o_r = 4'd7;
        6'b101110: o_r = 4'd14;
        6'b110000: o_r = 4'd10;
        6'b110010: o_r = 4'd15;
        6'b110100: o_r = 4'd6;
        6'b110110: o_r = 4'd8;
        6'b111000: o_r = 4'd0;
        6'b111010: o_r = 4'd5;
        6'b111100: o_r = 4'd9;
        6'b111110: o_r = 4'd2;
        6'b100001: o_r = 4'd6;
        6'b100011: o_r = 4'd11;
        6'b100101: o_r = 4'd13;
        6'b100111: o_r = 4'd8;
        6'b101001: o_r = 4'd1;
        6'b101011: o_r = 4'd4;
        6'b101101: o_r = 4'd10;
        6'b101111: o_r = 4'd7;
        6'b110001: o_r = 4'd9;
        6'b110011: o_r = 4'd5;
        6'b110101: o_r = 4'd0;
        6'b110111: o_r = 4'd15;
        6'b111001: o_r = 4'd14;
        6'b111011: o_r = 4'd2;
        6'b111101: o_r = 4'd3;
        6'b111111: o_r = 4'd12;
    endcase
end

endmodule

module S8(
    input [5:0] i,
    output [3:0] o
);

reg [3:0] o_r;
assign o = o_r;

always @(*) begin
    case(i)
        6'b000000: o_r = 4'd13;
        6'b000010: o_r = 4'd2;
        6'b000100: o_r = 4'd8;
        6'b000110: o_r = 4'd4;
        6'b001000: o_r = 4'd6;
        6'b001010: o_r = 4'd15;
        6'b001100: o_r = 4'd11;
        6'b001110: o_r = 4'd1;
        6'b010000: o_r = 4'd10;
        6'b010010: o_r = 4'd9;
        6'b010100: o_r = 4'd3;
        6'b010110: o_r = 4'd14;
        6'b011000: o_r = 4'd5;
        6'b011010: o_r = 4'd0;
        6'b011100: o_r = 4'd12;
        6'b011110: o_r = 4'd7;
        6'b000001: o_r = 4'd1;
        6'b000011: o_r = 4'd15;
        6'b000101: o_r = 4'd13;
        6'b000111: o_r = 4'd8;
        6'b001001: o_r = 4'd10;
        6'b001011: o_r = 4'd3;
        6'b001101: o_r = 4'd7;
        6'b001111: o_r = 4'd4;
        6'b010001: o_r = 4'd12;
        6'b010011: o_r = 4'd5;
        6'b010101: o_r = 4'd6;
        6'b010111: o_r = 4'd11;
        6'b011001: o_r = 4'd0;
        6'b011011: o_r = 4'd14;
        6'b011101: o_r = 4'd9;
        6'b011111: o_r = 4'd2;
        6'b100000: o_r = 4'd7;
        6'b100010: o_r = 4'd11;
        6'b100100: o_r = 4'd4;
        6'b100110: o_r = 4'd1;
        6'b101000: o_r = 4'd9;
        6'b101010: o_r = 4'd12;
        6'b101100: o_r = 4'd14;
        6'b101110: o_r = 4'd2;
        6'b110000: o_r = 4'd0;
        6'b110010: o_r = 4'd6;
        6'b110100: o_r = 4'd10;
        6'b110110: o_r = 4'd13;
        6'b111000: o_r = 4'd15;
        6'b111010: o_r = 4'd3;
        6'b111100: o_r = 4'd5;
        6'b111110: o_r = 4'd8;
        6'b100001: o_r = 4'd2;
        6'b100011: o_r = 4'd1;
        6'b100101: o_r = 4'd14;
        6'b100111: o_r = 4'd7;
        6'b101001: o_r = 4'd4;
        6'b101011: o_r = 4'd10;
        6'b101101: o_r = 4'd8;
        6'b101111: o_r = 4'd13;
        6'b110001: o_r = 4'd15;
        6'b110011: o_r = 4'd12;
        6'b110101: o_r = 4'd9;
        6'b110111: o_r = 4'd0;
        6'b111001: o_r = 4'd3;
        6'b111011: o_r = 4'd5;
        6'b111101: o_r = 4'd6;
        6'b111111: o_r = 4'd11;
    endcase
end

endmodule

