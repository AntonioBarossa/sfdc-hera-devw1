public with sharing class HDT_WRP_AddressObject {

    @AuraEnabled Public String stato { get; set; }
	@AuraEnabled Public String provincia { get; set; }
	@AuraEnabled Public String comune { get; set; }
	@AuraEnabled Public string cap { get; set; }
	@AuraEnabled Public string via { get; set; }
	@AuraEnabled Public string civico { get; set; }
	@AuraEnabled Public String codiceComuneSAP { get; set; }
	@AuraEnabled Public String estensCivico { get; set; }
    @AuraEnabled Public String codiceViaStradarioSAP { get; set; }
    @AuraEnabled Public Boolean flagForzato { get; set; }
    @AuraEnabled Public Boolean flagVerificato { get; set; }
    @AuraEnabled Public String localita { get; set; }
    @AuraEnabled Public String codiceLocalita { get; set; }

    public HDT_WRP_AddressObject(){
        System.debug('HDT_WRP_AddressObject empty constructor');
    }
    
    public HDT_WRP_AddressObject(String stato, string provincia, string comune, 
                                    string cAP, string via, string civico, 
                                    string codiceComuneSAP, string estensCivico, string codiceViaStradarioSAP,Boolean flagForzato,Boolean flagVerificato,String localita,String codiceLocalita) 
    {

        this.stato = stato;
		this.provincia= provincia;
		this.via = via;
		this.cap= cAP;
		this.comune = comune;
		this.civico = civico;
		this.codiceComuneSAP = codiceComuneSAP	;
		this.estensCivico= estensCivico	;
        this.codiceViaStradarioSAP = codiceViaStradarioSAP;
        this.flagForzato = flagForzato;
        this.flagVerificato = flagVerificato;
        this.localita= localita;
        this.codiceLocalita = codiceLocalita;
    }

    @AuraEnabled(cacheable=true)
    public static HDT_WRP_AddressObject getInstance(){

        HDT_WRP_AddressObject h = new HDT_WRP_AddressObject();
        return h;
     
    }

}
