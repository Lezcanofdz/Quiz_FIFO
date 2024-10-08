class driver #(parameter width =16);
    virtual fifo_if #(.width(width))vif;
    trans_fifo_mbx agent_drv_mbx;
    trans_fifo_mbx drv_chkr_mbx;
    int espera;

    task run();
        $display("[%g] El driver fue inicializado.", $time);
        @(posedge vif.clk);
        vif.rst = 1;
        @(posedge vif.clk);
        forever begin
            trans_fifo #(.width(width)) transaction;
            vif.push =0;
            vif.rst =0;
            vif.pop =0;
            vif.dato_in =0;
            $display("[%g] El driver espera por una transaccion.", $time);
            espera = 0;
            @(posedge vif.clk);
            agent_drv_mbx.get(transaction);
            transaction.print("Driver: Trasaccion recibida.");
            $display ("Transacciones pendientes en el mbx agent_drv = %g", agent_drv_mbx.num());

            while (espera < transaction.retardo) begin
                @(posedge vif.clk);
                espera = espera +1;
                vif.dato_in = transaction.dato;
            end

            case (transaction.tipo)
                lectura: begin
                    transaction.dato = vif.dato_out;
                    transaction.tiempo = $tiempo;
                    @(posedge vif.clk);
                    vif.pop =1;
                    drv_chkr_mbx.put(transaction);
                    transaction.print("Driver: Transaccion ejecutada");
                end

                escritura: begin
                    vif.push =1;
                    transaction.tiempo = $time;
                    drv_chkr_mbx.put(transaction);
                    transaction.print("Driver: Transaccion ejecutada");
                end

                lectura_escritura: begin
                                                        // Escritura
                    vif.push = 1;                       // Activa la señal de push para indicar que quiere escribir en la fifo
                    vif.dato_in = transaccion.dato;     // Coloca el cado en dato_in
                    @(posedge vif.clk);                 // Se sinroniza con un flanco positivo
                    vif.push = 0;                       // Desactiva la señal para indicar que ya completo el push
                                                        // Lectura
                    vif.pop = 1;                        // Activa la señal de pop para leer de la fifo
                    @(posedge vif.clk);                 //
                    vif.pop = 0;                        // Desactiva la señal de pop
                    transaction.tiempo = $time;         // Tiempo de la transaccion
                    drv_chkr_mbx.put(transaction);      // Envía la transacción al checker
                    transaction.print("Driver: Transaccion ejecutada");
                end

                reset: begin
                    vif.rst =1;
                    transaction.tiempo = $time;
                    drv_chkr_mbx.put(transaction);
                    transaction.print("Driver: Transaccion ejectutada.");
                end

                default: begin
                    $display("[%g] Driver error: la transaccion recibida no tiene tipo valido.", $time);
                    $finish;
                end
            endcase
            @(posedge vif.clk);

        end
    endtask
endclass
