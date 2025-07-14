module axi4_lite_interconnect_m1s2 #(
    /* parameters */
    parameter ADDR_WIDTH    = 32,
    parameter DATA_WIDTH    = 32,

    /* address parameters */
    parameter LOW_ADDR0     = 32'h0000_0000,
    parameter HIGH_ADDR0    = 32'h0000_FFFF,
    parameter LOW_ADDR1     = 32'h0001_0000,
    parameter HIGH_ADDR1    = 32'h0001_FFFF
) (
    input                               iCLK, iRST,

    /* master interface 0 */
        /* write address channel */    
        input                           m0_AWVALID,
        input   [ADDR_WIDTH-1:0]        m0_AWADDR,
        output                          m0_AWREADY,

        /* write data channel */    
        input                           m0_WVALID,
        input   [(DATA_WIDTH/8)-1:0]    m0_WSTRB,
        input   [DATA_WIDTH-1:0]        m0_WDATA,
        output                          m0_WREADY,

        /* write response channel */    
        input                           m0_BREADY,
        output                          m0_BVALID,
        output  [1:0]                   m0_BRESP,

        /* read address channel */    
        input                           m0_ARVALID,
        input   [DATA_WIDTH-1:0]        m0_ARADDR,
        output                          m0_ARREADY,

        /* read data channel */    
        input                           m0_RREADY,
        output                          m0_RVALID,
        output  [1:0]                   m0_RRESP,
        output  [DATA_WIDTH-1:0]        m0_RDATA,

    /* slave interface 0 */
        /* write address channel */
        input                           s0_AWREADY,
        output                          s0_AWVALID,
        output  [ADDR_WIDTH-1:0]        s0_AWADDR,

        /* write data channel */
        input                           s0_WREADY,
        output                          s0_WVALID,
        output  [(DATA_WIDTH/8)-1:0]    s0_WSTRB,
        output  [DATA_WIDTH-1:0]        s0_WDATA,

        /* write response channel */
        input                           s0_BVALID,
        input   [1:0]                   s0_BRESP,
        output                          s0_BREADY,

        /* read address channel */
        input                           s0_ARREADY,
        output                          s0_ARVALID,
        output  [ADDR_WIDTH-1:0]        s0_ARADDR,

        /* read data channel */
        input                           s0_RVALID,
        input   [1:0]                   s0_RRESP,
        input   [DATA_WIDTH-1:0]        s0_RDATA,
        output                          s0_RREADY,

    /* slave interface 1 */
        /* write address channel */
        input                           s1_AWREADY,
        output                          s1_AWVALID,
        output  [ADDR_WIDTH-1:0]        s1_AWADDR,

        /* write data channel */
        input                           s1_WREADY,
        output                          s1_WVALID,
        output  [(DATA_WIDTH/8)-1:0]    s1_WSTRB,
        output  [DATA_WIDTH-1:0]        s1_WDATA,

        /* write response channel */
        input                           s1_BVALID,
        input   [1:0]                   s1_BRESP,
        output                          s1_BREADY,

        /* read address channel */
        input                           s1_ARREADY,
        output                          s1_ARVALID,
        output  [ADDR_WIDTH-1:0]        s1_ARADDR,

        /* read data channel */
        input                           s1_RVALID,
        input   [1:0]                   s1_RRESP,
        input   [DATA_WIDTH-1:0]        s1_RDATA,
        output                          s1_RREADY
);

    /* finite state machine */
    localparam IDLE     = 3'b000;
    localparam WRITE    = 3'b001;
    localparam READ     = 3'b010;

    reg         read_start, write_start;
    reg [1:0]   sel_m;
    reg [1:0]   sel_s;
    reg [1:0]   sel_s_reg;
    reg [1:0]   sel_m_reg;
    reg [2:0]   state, next_state;

    initial begin
        sel_s       = 2;
        sel_m       = 1;
    end

    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            state           <= IDLE;
            sel_s_reg       <= 2;
            sel_m_reg       <= 1;
        end else begin
            state           <= next_state;
            if (state == IDLE) begin
                sel_s_reg   <= sel_s;
                sel_m_reg   <= sel_m;
            end
        end
    end

    always @(*) begin
        case (state)
            IDLE: next_state = (write_start) ? WRITE : ((read_start) ? READ : IDLE);
            WRITE: begin
                case(sel_s)
                    0: next_state = (s0_BVALID && m0_BREADY) ? IDLE : WRITE;
                    1: next_state = (s1_BVALID && m0_BREADY) ? IDLE : WRITE;
                    default: next_state = WRITE;
                endcase
            end
            READ : begin
                case(sel_s)
                    0: next_state = (s0_RVALID && m0_RREADY) ? IDLE : READ;
                    1: next_state = (s1_RVALID && m0_RREADY) ? IDLE : READ;
                    default: next_state = READ;
                endcase
            end
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        read_start  = 0;
        write_start = 0;
        if (state == IDLE) begin
            if (m0_ARVALID) begin 
                sel_m = 0; write_start = 0; read_start = 1;
            end else if (m0_AWVALID) begin
                sel_m = 0; write_start = 1; read_start = 0;
            end
            else sel_m = 1;
        end else sel_m = sel_m_reg;
    end

    always @(*) begin
        if (state == IDLE) begin
            if (write_start) begin
                case (sel_m)
                    0: begin
                        if      (m0_AWADDR >= LOW_ADDR0 && m0_AWADDR <= HIGH_ADDR0) sel_s = 0;
                        else if (m0_AWADDR >= LOW_ADDR1 && m0_AWADDR <= HIGH_ADDR1) sel_s = 1;
                        else    sel_s = 2;
                    end
                    default: sel_s = 2;
                endcase
            end
            else if (read_start) begin
                case (sel_m)
                    0: begin
                        if      (m0_ARADDR >= LOW_ADDR0 && m0_ARADDR <= HIGH_ADDR0) sel_s = 0;
                        else if (m0_ARADDR >= LOW_ADDR1 && m0_ARADDR <= HIGH_ADDR1) sel_s = 1;
                        else    sel_s = 2;
                    end
                    default: sel_s = 2;
                endcase
            end else sel_s = 2;
        end else  sel_s = sel_s_reg;
    end

    /* master 0 */
        /* write */
        assign m0_AWREADY   = (sel_s_reg == 0) ? s0_AWREADY : (sel_s_reg == 1) ? s1_AWREADY : 1'b0;
        assign m0_WREADY    = (sel_s_reg == 0) ? s0_WREADY  : (sel_s_reg == 1) ? s1_WREADY  : 1'b0;
        assign m0_BRESP     = (sel_s_reg == 0) ? s0_BRESP   : (sel_s_reg == 1) ? s1_BRESP   : 2'b00;
        assign m0_BVALID    = (sel_s_reg == 0) ? s0_BVALID  : (sel_s_reg == 1) ? s1_BVALID  : 1'b0;

        /* read */
        assign m0_ARREADY   = (sel_s_reg == 0) ? s0_ARREADY : (sel_s_reg == 1) ? s1_ARREADY : 1'b0;
        assign m0_RVALID    = (sel_s_reg == 0) ? s0_RVALID  : (sel_s_reg == 1) ? s1_RVALID  : 1'b0;
        assign m0_RDATA     = (sel_s_reg == 0) ? s0_RDATA   : (sel_s_reg == 1) ? s1_RDATA   : 32'h0;
        assign m0_RRESP     = (sel_s_reg == 0) ? s0_RRESP   : (sel_s_reg == 1) ? s1_RRESP   : 2'b00;

    /* slave 0 */
        /* write */
        assign s0_AWADDR   = ((sel_s_reg == 0) && m0_AWVALID && (sel_m_reg == 0)) ? m0_AWADDR - LOW_ADDR0   : 32'h0;
        assign s0_AWVALID  = ((sel_s_reg == 0) && m0_AWVALID && (sel_m_reg == 0)) ? m0_AWVALID              : 1'b0;
        assign s0_WVALID   = ((sel_s_reg == 0) && m0_WVALID  && (sel_m_reg == 0)) ? m0_WVALID               : 1'b0;
        assign s0_WDATA    = ((sel_s_reg == 0) && m0_WDATA   && (sel_m_reg == 0)) ? m0_WDATA                : 32'h0;
        assign s0_WSTRB    = ((sel_s_reg == 0) && m0_WSTRB   && (sel_m_reg == 0)) ? m0_WSTRB                : 4'h0;
        assign s0_BREADY   = ((sel_s_reg == 0) && m0_BREADY  && (sel_m_reg == 0)) ? m0_BREADY               : 1'b0;

        /* read */
        assign s0_ARADDR   = ((sel_s_reg == 0) && m0_ARVALID && (sel_m_reg == 0)) ? m0_ARADDR - LOW_ADDR0   : 32'h0;
        assign s0_ARVALID  = ((sel_s_reg == 0) && m0_ARVALID && (sel_m_reg == 0)) ? m0_ARVALID              : 1'b0;
        assign s0_RREADY   = ((sel_s_reg == 0) && m0_RREADY  && (sel_m_reg == 0)) ? m0_RREADY               : 1'b0;

    /* slave 1 */
        /* write */
        assign s1_AWADDR   = ((sel_s_reg == 1) && m0_AWVALID && (sel_m_reg == 0)) ? m0_AWADDR - LOW_ADDR1   : 32'h0;
        assign s1_AWVALID  = ((sel_s_reg == 1) && m0_AWVALID && (sel_m_reg == 0)) ? m0_AWVALID              : 1'b0;
        assign s1_WVALID   = ((sel_s_reg == 1) && m0_WVALID  && (sel_m_reg == 0)) ? m0_WVALID               : 1'b0;
        assign s1_WDATA    = ((sel_s_reg == 1) && m0_WDATA   && (sel_m_reg == 0)) ? m0_WDATA                : 32'h0;
        assign s1_WSTRB    = ((sel_s_reg == 1) && m0_WSTRB   && (sel_m_reg == 0)) ? m0_WSTRB                : 4'h0;
        assign s1_BREADY   = ((sel_s_reg == 1) && m0_BREADY  && (sel_m_reg == 0)) ? m0_BREADY               : 1'b0;

        /* read */
        assign s1_ARADDR   = ((sel_s_reg == 1) && m0_ARVALID && (sel_m_reg == 0)) ? m0_ARADDR - LOW_ADDR1   : 32'h0;
        assign s1_ARVALID  = ((sel_s_reg == 1) && m0_ARVALID && (sel_m_reg == 0)) ? m0_ARVALID              : 1'b0;
        assign s1_RREADY   = ((sel_s_reg == 1) && m0_RREADY  && (sel_m_reg == 0)) ? m0_RREADY               : 1'b0;

endmodule