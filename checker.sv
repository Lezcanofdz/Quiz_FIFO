class checker #(parameter width=16, parameter depth =8);
    trans_fifo #(.width(width)) transaccion;
    trans_fifo #(.width(width)) auxiliar;
    trans_sb #(.width(width)) to_sb;
    trans_fifo emul_fifo[$];
    trans_fifo_mbx drv_chkr_mbx;
    trans_sb_mbx chkr_sb_mbx;
    int contador_auxiliar;

    function new();
        this.emul_fifo = {};
        this.contador_auxiliar = 0;
    endfunction

    task run;
        $display("[%g] El checker fue inicializado.", $time);
        to_sb = new();
        forever begin
            to_sb = new();
            drv_chkr_mbx.bet(transaccion);
            transaccion.print("Checker: Se recibe transacción desde el driver.");
            to_sb.clean();
            
            case(transaccion.tipo)
                lectura: begin
                    if(0 !== emul_fifo.size()) begin
                        auxiliar = emul_fifo.pop_front();
                        if (transaccion.dato == auxiliar.dato) begin
                            to_sb.dato_enviado = auxiliar.dato;
                            to_sb.tiempo_push = auxiliar.tiempo;
                            to_sb.tiempo_pop = trasaccion.dato;
                            to_sb.completado = 1;
                            to_sb.calc_latencia();
                            to_sb.print ("Checker: Transaccion Completa.");
                            chkr_sb_mbx.put(to_sb);
                        end else begin
                            transaccion.print("Checker: Error en el dato de la transaccion, no calza con lo esperado.");
                            $display("Dato_leido = %h, Dato_Esperado = %h", transaccion.dato,auxiliar.dato);
                            $finish
                        end
                    end else begin
                        to_sb.tiempo_pop = transaccion.tiempo;
                        to_sb.underflow = 1;
                        to_sb.print("Checker: Underflow.");
                        chkr_sb_mbx.put(to_sb);
                    end
                end
                escritura: begin
                    if(emul_fifo.size() == depth) begin

                        auxiliar = emul_fifo.pop_front();
                        to_sb.dato_enviado = auxiliar.dato;
                        to_sb.tiempo_push = auxiliar.tiempo; 
                        to_sb.overflow = 1; 
                        to_sb.print("Checker:Overflow");
                        chkr_sb_mbx.put(to_sb);
                        emul_fifo.push_back(transaccion);

                    end else begin 

                        transaccion.print ("Checker: Escritura");
                        emul_fifo.push_back(transaccion); 
                    end
                end

                lectura_escritura: begin
                    
                    if (emul_fifo.size() < depth) begin
                        
                        emul_fifo.push_back(transaccion);  
                        to_sb.dato_escrito = transaccion.dato;
                        to_sb.tiempo_push = transaccion.tiempo;
                        $display("Checker: Dato %h escrito correctamente.", transaccion.dato);
                    end else begin
                        
                        to_sb.overflow = 1;
                        to_sb.print("Checker: Overflow en la transacción de escritura.");
                        chkr_sb_mbx.put(to_sb);
                        $finish;
                    end
                end


                reset: begin
                    
                    contador_auxiliar = emul_fifo.size(); 
                    for (int i = 0; i<contador_auxiliar; i++) begin
                        auxiliar = emul_fifo.pop_front(); 
                        to_sb.clean();
                        to_sb.dato_enviado = auxiliar.dato; 
                        to_sb.tiempo_push = auxiliar.tiempo; 
                        to_sh.reset = 1;
                        to _sb.print ( "Checker: Reset." ); 
                        chkr_sb_mbx.put(to_sb);
                    end
                end

                default: begin 
                    $display("[%g] Checker Error: La transacción recibidano tiene tipo valido", $time);
                    $finish;
                end
            endcase 
        end
    endtask 
endclass


