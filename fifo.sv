//Definicion del tipo de trasacción

typedef enum  { lectura, escritura,lectura_escritura, reset} tipo_trans;

//Transacción: este objeto representa las transacciones que entran y salen de la FiFo 

class trans_fifo #(parameter width = 16);
    rand int retardo; //Tiempo de retardo en ciclos de reloj que se deben de esperar antes de realizar la transaccion.
    rand bit[width-1:0] dato; //Dato de la trasaccion
    int tiempo;
    rand tipo_trans tipo;
    int max_retardo;

    constraint cons_retardo {retardo < max_retardo; retardo>0;}

    function new(int ret = 0 , bit[width-1:0] dto =0, int tmp =0, tipo_trans tpo = lectura, int mx_rtrd = 10);
        this.retardo = ret;
        this.dato = dto;
        this.tiempo = tmp;
        this.tipo = tpo;
        this.max_retardo = mx_rtrd;
    endfunction

    function clean;
        this.retardo = 0;
        this.dato = 0;
        this.tiempo =0;
        this.tipo =lectura;   
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Tiempo=%g Tipo=%s Retardo=%g dato=0x%h", $time,tag,tiempo,this.tipo,this.retardo,this.dato);
    endfunction
endclass
