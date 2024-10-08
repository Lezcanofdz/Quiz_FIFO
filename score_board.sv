class score_board #(parameter width = 16);
    trans_sb_mbx chkr_sb_mbx;
    comando_test_sb_mbx test_sb_mbx;
    trans_sb #(.width(width)) transaccion_entrante;
    trans_sb scoreboard[$];
    trans_sb auxiliar_array[$];
    trans_sb auxiliar_trans;
    shortreal retardo_promedio;
    solicitud_sb orden;
    int tamano_sb = 0;
    int transacciones_completadas = 0;
    int retardo_local = 0;

    task run;
        $display("[%g] El scoreboard fue inicializado.", $time);
        forever begin
            #5
            if(chkr_sb_mbx.num()>0) begin

                chkr_sb_mbx.get(transaccion_entrante);
                transaccion_entrante.print("Score board: Transaccion recibida desde el checker.");
                if (transaccion_entrante.completado) begin
                    retardo_local = retardo_local + transaccion_entrante.latencia;
                    transacciones_completadas++;
                end
                scoreboard.push_back(transaccion_entrante);
            end else begin

                if(test_sb_mbx.num()>0) begin
                    test_sb_mbx.get(orden);
                    case(orden)
                        retardo_promedio: begin
                            $display("Score board: Recibida orden Retardo_promedio");
                            retardo_promedio = retardo_local / transacciones_completadas;
                            $display ("[%g] ScoreBoard: el retardo promedio es de : %0.3f", $time, Retardo_promedio);
                        end

                        reporte: begin
                            $display("Score Board: Recibida Ordn de reporte");
                            tamano_sb = this.scoreboard.size();
                            for (int i=0; i<tamano_sb; i++) begin
                                auxiliar_trans = scoreboard.pop_front;
                                auxiliar_trans.print("SB_report: ");
                                auxiliar_array.push_back (auxiliar_trans);
                            end
                            scoreboard = auxiliar_array;
                        end
                    endcase
                end
            end
        end
    endtask
endclass
