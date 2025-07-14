module axi4_lite_rom_wrapper #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input                               iCLK,
    input                               iRST,
    
    /* write address channel */
    input                               s_AWVALID,
    input       [2:0]                   s_AWPROT,
    input       [ADDR_WIDTH-1:0]        s_AWADDR,
    output                              s_AWREADY,
    
    /* write data channel */
    input                               s_WVALID,
    input       [DATA_WIDTH-1:0]        s_WDATA,
    input       [(DATA_WIDTH/8)-1:0]    s_WSTRB,
    output                              s_WREADY,
    
    /* write response channel */
    input                               s_BREADY,
    output                              s_BVALID,
    output      [1:0]                   s_BRESP,
    
    /* read address channel */
    input                               s_ARVALID,
    input       [2:0]                   s_ARPROT,
    input       [ADDR_WIDTH-1:0]        s_ARADDR,
    output                              s_ARREADY,
    
    /* read data channel */
    input                               s_RREADY,
    output                              s_RVALID,
    output      [1:0]                   s_RRESP,
    output      [DATA_WIDTH-1:0]        s_RDATA
);

    /* read interfaces */
    wire                            read_req, read_done;
    wire    [1:0]                   read_resp;
    wire    [ADDR_WIDTH-1:0]        read_addr;
    wire    [DATA_WIDTH-1:0]        read_data;
    reg     [ADDR_WIDTH-1:0]        read_addr_reg;

    /* response codes */
	localparam OKAY     = 2'b00;
	localparam EXOKAY   = 2'b01;
	localparam SLVERR   = 2'b10;
	localparam DECERR   = 2'b11;

    axi4_lite_slave #(
        .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)
    ) axi_slave (
        .iCLK(iCLK), .iRST(iRST),
        
        /* write */
        .s_AWREADY(s_AWREADY), .s_AWVALID(s_AWVALID), .s_AWPROT(s_AWPROT), .s_AWADDR(s_AWADDR),
        .s_WREADY(s_WREADY), .s_WVALID(s_WVALID), .s_WDATA(s_WDATA), .s_WSTRB(s_WSTRB),
        .s_BVALID(s_BVALID), .s_BRESP(s_BRESP), .s_BREADY(s_BREADY),
        
        /* read */
        .s_ARREADY(s_ARREADY), .s_ARVALID(s_ARVALID), .s_ARPROT(s_ARPROT), .s_ARADDR(s_ARADDR),
        .s_RVALID(s_RVALID), .s_RRESP(s_RRESP), .s_RDATA(s_RDATA), .s_RREADY(s_RREADY),

        /* interface */
        .read_addr(read_addr), .read_data(read_data), .read_resp(read_resp)
    );

    /* logic */
    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            read_addr_reg       <= {ADDR_WIDTH{1'b0}};
        end else begin
            if (s_ARVALID && s_ARREADY)     read_addr_reg   <= s_ARADDR;
        end
    end

    /* assigns */
    assign read_req     = s_RREADY;
    assign read_resp    = OKAY;

    /* intances */
    memory_rom rom (
        .iROM_ADDR(read_addr_reg), .oROM_DATA(read_data),
        .iROM_RD(read_req), .iROM_CE(read_req)
    );

endmodule