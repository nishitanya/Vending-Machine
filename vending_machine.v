module vending_machine(
    input clk,
    input rst,
    input [1:0] money, // 01 = 5 Rs, 10 = 10 Rs, 11 = 20 Rs
    output reg [1:0] product_select, // 01 = 5 Rs product, 10 = 10 Rs product, 11 = 15 Rs product
    output reg [1:0] change, // Change returned
    output reg product_dispensed
);

    // State encoding
    parameter s0 = 2'b00; // Initial state
    parameter s1 = 2'b01; // After 5 Rs
    parameter s2 = 2'b10; // After 10 Rs
    parameter s3 = 2'b11; // After 20 Rs

    reg [1:0] c_state, n_state;

    always @(posedge clk or posedge rst) begin
        if (rst) 
            c_state <= s0;
        else 
            c_state <= n_state;
    end

    always @(c_state, money) begin
        // Default values
        n_state = c_state;
        product_select = 2'b00;
        change = 2'b00;
        product_dispensed = 0;

        case (c_state)
            s0: begin
                if (money == 2'b01) // Rs 5 inserted
                    n_state = s1;
                else if (money == 2'b10) // Rs 10 inserted
                    n_state = s2;
                else if (money == 2'b11) // Rs 20 inserted
                    n_state = s3;
            end

            s1: begin
                if (money == 2'b01) begin // Another Rs 5 inserted
                    n_state = s2;
                end else if (money == 2'b10) begin // Rs 10 inserted
                    product_select = 2'b10; // Rs 10 product
                    product_dispensed = 1;
                    n_state = s0;
                end else if (money == 2'b11) begin // Rs 20 inserted
                    product_select = 2'b10; // Rs 10 product
                    product_dispensed = 1;
                    change = 2'b01; // Rs 5 change
                    n_state = s0;
                end
            end

            s2: begin
                if (money == 2'b01) begin // Rs 5 inserted
                    product_select = 2'b11; // Rs 15 product
                    product_dispensed = 1;
                    n_state = s0;
                end else if (money == 2'b10) begin // Rs 10 inserted
                    product_select = 2'b11; // Rs 15 product
                    product_dispensed = 1;
                    change = 2'b01; // Rs 5 change
                    n_state = s0;
                end else if (money == 2'b11) begin // Rs 20 inserted
                    product_select = 2'b11; // Rs 15 product
                    product_dispensed = 1;
                    change = 2'b10; // Rs 10 change
                    n_state = s0;
                end
            end

            s3: begin
                product_select = 2'b11; // Rs 15 product
                product_dispensed = 1;
                change = 2'b01; // Rs 5 change
                n_state = s0;
            end
        endcase
    end
endmodule
