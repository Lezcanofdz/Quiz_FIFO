
interface fifo #(parameter width = 16) (
    input clk
);
    logic rst;
    logic pndng;
    logic full;
    logic push;
    logic pop;
    logic [width-1:0]dato_in;
    logic [width-1:0] dato_out;


    
endinterface 


//Objeto de transacción usado en el scoreboard.

class trans_sb #(parameter width=16);
    bit [width-1:0] dato_enviado;
    int tiempo_push;
    int tiempo_pop;
    bit completado;
    bit overflow;
    bit underflow;
    bit reset;
    int latencia;

    function clean():
        this.dato_enviado= 0 ;
        this.tiempo_push= 0 ; 
        this.tiempo_pop = 0 ; 
        this.completado = 0 ; 
        this.overflow= 0 ;
        this.underflow= 0 ;
        this.reset= 0;
        this.latencia=0;
    endfunction

    task calc_latencia;
        this.latencia = this.tiempo_pop - this.tiempo_push;
    endtask

    function print (string tag);
        $display("[%g] %s dato=%h, t_push=%g, t_pop=%g, cmplt=%g, ovrflw=%g, undrflw=%g, rst=%g, ltncy=%g" ,
                $time,
                tag,
                this.dato_enviado,
                this.tiempo_push,
                this.tiempo_pop,
                this.completado.
                this.overflow.
                this.underflow,
                this.reset,
                this.latencia);

    endfunction
endclass


//Definición de estructura para generar comandos hacia el scoreboard
typedef enum {retardo_promedio,reporte} solicitud_sb;

//Definición de estructura para generar comandos hacia el agente
typedef enum {llenado_aleatorio, trans_aleatoria, trans_especifica, sec_trans_aleatorias} instrucciones_agente;


//Definición de mailboxes de tipo definido trans_fifo para comunicar las interfaces
typedef mailbox #(trans_fifo) trans_fifo_mbx;
typedef mailbox #(trans_sb) trans_sb_mbx;
typedef mailbox #(solicitud_sb) comando_test_sb_mbx;
typedef mailbox #(instrucciones_agente) comando_test_agent_mbx;
typedef mailbox #(trans_fifo) drv_chkr_mbx; 