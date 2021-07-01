public with sharing class HDT_UTL_Sales {
    
    public static map<String,String> mapMarcatura = new Map<String,String>();//'AAS Associazione' => 'AAS','AAS Azienda'=> 'AAS','AAS Condominio'=> 'AAS','AAS Ditta individuale'=> 'AAS','AAS Parti comuni'=> 'AAS','AAS Persona fisica'=> 'AAS'}; 
    public static String getCityAgency(String comune,boolean isEle, boolean isGas){
        String getSDVComune = '';
        
        if(isEle){
            getSDVComune = HDT_QR_City.getCitySDVEle(comune);
        }
        else if(isGas){
            getSDVComune = HDT_QR_City.getCitySDVGas(comune);
        }

        return getSDVComune;
    }

    public static Map<String,String> getAgentNameAndCode(ServicePoint__c Service,String Marcatura){
        String marcaturaValue = '';
        Map<String,String> mapRes = new Map<String,String>();
        String comune = getCityAgency(service.SupplyCity__c,Service.CommoditySector__c == 'Energia Elettrica' ? true:false,Service.CommoditySector__c == 'Gas' ? true:false);
        if(mapMarcatura.get(Marcatura) != null && mapMarcatura.get(Marcatura) != ''){
            marcaturaValue = mapMarcatura.get(Marcatura);
        }
        else{
            marcaturaValue = 'ALTRO';
        }
        if(comune == null || comune == ''){
            comune = 'ALTRO';
        }
        System.debug('***Comune:' + comune);
        System.debug('***Service:' + Service.CommoditySector__c);
        System.debug('***Marcatura:' + marcaturaValue);
        List<HDT_MatriceSocietaVendita__mdt> listConf = new List<HDT_MatriceSocietaVendita__mdt>();
        if(service.distributor__c != null){
            listConf = HDT_QR_MatriceAgenti.getAgenteException(Service.CommoditySector__c,comune,marcaturaValue,'ALTRO',service.distributor__r.code__c);
        }
        if(listConf != null && listConf.isEmpty()){
            listConf = HDT_QR_MatriceAgenti.getAgente(Service.CommoditySector__c,comune,marcaturaValue,'ALTRO');
        }

        if(listConf != null && !listConf.isEmpty()){
            mapRes.put('nomeAgente',listConf[0].SellerCompany__c);
            mapRes.put('codiceAgente',listConf[0].SalesCompanyCode__c);
        }else{
            mapRes.put('nomeAgente','');
            mapRes.put('codiceAgente','');
        }
        return mapRes;
    }

}
