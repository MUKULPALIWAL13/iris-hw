module fifo_logger (
    input aclk,
    input aresetn,
    input [31:0] fifo_data,
    input fifo_valid
);

    integer file;
    
    initial begin
        file = $fopen("fifo_output.txt", "w"); // Open file for writing
        if (file == 0) begin
            $display("Error opening file!");
            $finish;
        end
    end
    
    always @(posedge aclk) begin
        if (!aresetn) begin
            // Optionally, you can close and reopen the file on reset if needed
        end else if (fifo_valid) begin
            $fwrite(file, "%d\n", fifo_data); // Write FIFO data to file in hex format
        end
    end
    
    // final begin
    //     $fclose(file); // Close file at the end of simulation
    // end
    
endmodule
