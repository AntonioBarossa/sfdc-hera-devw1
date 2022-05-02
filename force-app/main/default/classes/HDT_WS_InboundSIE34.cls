/**
 * @author Fabio Palladino, fabio.palladino@nttdata.com
 * @version 1.0
 * @description: espone un servizio di arricchimento del tracciato della SIE34 invocato da MuleSoft.
 *               Accetta richieste in Get per singolo ordine o in post ricevendo una lista di ordini.
 *               Sfrutta il calcolo del servizio 26 per ricavare gli operandi posizionali dei Bonus/Contributi/VAS
 *               e li mappa sui campi del tracciato della SIE
 * @history
 * @Created 28/04/2022
 * Modified By:
 **/
@RestResource(urlMapping='/SIE34InboundServices/*')
global with sharing class HDT_WS_InboundSIE34 {

    @HttpGet
    global static List<HDT_WRP_SIE108OrderEnrichment> getSIE34SingleOrder() {
        RestRequest req = RestContext.request;
        String orderId  = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<HDT_WRP_SIE108OrderEnrichment> response = new List<HDT_WRP_SIE108OrderEnrichment>();
        HDT_WRP_SIE108OrderEnrichment responseItem = mapOutputResponse(orderId);
        response.add(responseItem);
        return response;
    }

    @HttpPost
    global static List<HDT_WRP_SIE108OrderEnrichment> doPostSIE34ListOrder(List<String> orderList)  {
        List<HDT_WRP_SIE108OrderEnrichment> response = new List<HDT_WRP_SIE108OrderEnrichment>();
        for(String orderId : orderList){
            HDT_WRP_SIE108OrderEnrichment responseItem = mapOutputResponse(orderId);
            response.add(responseItem);
        }
        return response;       
    }

    private static HDT_WRP_SIE108OrderEnrichment mapOutputResponse(String orderId){
        HDT_WRP_SIE108OrderEnrichment responseItem = new HDT_WRP_SIE108OrderEnrichment();
        responseItem.orderId = orderId;       
        
        // Invoke service 26 mapping
        HDT_UTL_ServiceTwentySix reqClass = new HDT_UTL_ServiceTwentySix();
        HDT_UTL_ServiceTwentySix.HDT_WRP_DtoServiceTwentySix reqClassResult = new HDT_UTL_ServiceTwentySix.HDT_WRP_DtoServiceTwentySix();
        try {
            reqClassResult = reqClass.startProcess(orderId);
        } catch (Exception e) {
            // build empty result
            reqClassResult.elements = new List<HDT_UTL_ServiceTwentySix.HDT_WRP_Position>();
        }
        reqClassResult.elements = (reqClassResult.elements == null) ? new List<HDT_UTL_ServiceTwentySix.HDT_WRP_Position>() : reqClassResult.elements;
        // Mapping Output      
        for(HDT_UTL_ServiceTwentySix.HDT_WRP_Position element : reqClassResult.elements){ 
            List<String> positionsInFile = SIE34MAPPINGFIELDS.get(element.field);
            if(positionsInFile != null ){
                if(!String.isBlank(positionsInFile[0])){
                    responseItem.orderEnrichmentList.add(new HDT_WRP_SIE108OrderEnrichment.HDT_WRP_SIE108Positions(positionsInFile[0], element.value));    
                }
                if(!String.isBlank(positionsInFile[1])){
                    responseItem.orderEnrichmentList.add(new HDT_WRP_SIE108OrderEnrichment.HDT_WRP_SIE108Positions(positionsInFile[1], element.value?.substringBeforeLast('_')));
                }             
            }          
        }
       return responseItem;
    }

    // Map from operands to SIE34 file columns
    private static Map<String,List<String>> SIE34MAPPINGFIELDS = new Map<String,List<String>>{
        'ZDV_ER_BN_P_01' => new List<String>{'Bonus Percentule 1','Bonus Percentule 1 da stampare'},
        'ZDV_ER_BN_P_02' => new List<String>{'Bonus Percentule 2','Bonus Percentule 2 da stampare'},
        'ZDV_ER_BN_P_03' => new List<String>{'Bonus Percentule 3','Bonus Percentule 3 da stampare'},
        'ZDV_ER_BN_P_04' => new List<String>{'Bonus Percentule 4','Bonus Percentule 4 da stampare'},
        'ZDV_ER_BN_G_01' => new List<String>{'Bonus Eur/gg 1','Bonus Eur/gg 1 da stampare'},
        'ZDV_ER_BN_G_02' => new List<String>{'Bonus Eur/gg 2','Bonus Eur/gg 2 da stampare'},
        'ZDV_ER_BN_G_03' => new List<String>{'Bonus Eur/gg 3','Bonus Eur/gg 3 da stampare'},
        'ZDV_ER_BN_G_04' => new List<String>{'Bonus Eur/gg 4','Bonus Eur/gg 4 da stampare'},
        'ZDV_ER_BN_M_01' => new List<String>{'Bonus Eur/Mese 1','Bonus Eur/Mese 1 da stampare'},
        'ZDV_ER_BN_M_02' => new List<String>{'Bonus Eur/Mese 2','Bonus Eur/Mese 2 da stampare'},
        'ZDV_ER_BN_M_03' => new List<String>{'Bonus Eur/Mese 3','Bonus Eur/Mese 3 da stampare'},
        'ZDV_ER_BN_M_04' => new List<String>{'Bonus Eur/Mese 4','Bonus Eur/Mese 4 da stampare'},
        'ZDV_ER_BN_V_01' => new List<String>{'Bonus Eur/kWh 1','Bonus Eur/kWh 1 da stampare'},
        'ZDV_ER_BN_V_02' => new List<String>{'Bonus Eur/kWh 2','Bonus Eur/kWh 2 da stampare'},
        'ZDV_ER_BN_V_03' => new List<String>{'Bonus Eur/kWh 3','Bonus Eur/kWh 3 da stampare'},
        'ZDV_ER_BN_V_04' => new List<String>{'Bonus Eur/kWh 4','Bonus Eur/kWh 4 da stampare'},
        'ZDV_ER_CF_V_01' => new List<String>{'Contributo Eur/kWh 1','Contributo Eur/kWh 1 da stampare'},
        'ZDV_ER_CF_V_02' => new List<String>{'Contributo Eur/kWh 2','Contributo Eur/kWh 2 da stampare'},
        'ZDV_ER_CF_V_03' => new List<String>{'Contributo Eur/kWh 3','Contributo Eur/kWh 3 da stampare'},
        'ZDV_ER_CF_V_04' => new List<String>{'Contributo Eur/kWh 4','Contributo Eur/kWh 4 da stampare'},
        'ZDV_ER_CF_M_01' => new List<String>{'Contributo Eur/mese 1','Contributo Eur/mese 1 da stampare'},
        'ZDV_ER_CF_M_02' => new List<String>{'Contributo Eur/mese 2','Contributo Eur/mese 2 da stampare'},
        'ZDV_ER_CF_M_03' => new List<String>{'Contributo Eur/mese 3','Contributo Eur/mese 3 da stampare'},
        'ZDV_ER_CF_M_04' => new List<String>{'Contributo Eur/mese 4','Contributo Eur/mese 4 da stampare'},
        'ZDV_ER_CF_G_01' => new List<String>{'Contributo Eur/gg 1','Contributo Eur/gg 1 da stampare'},
        'ZDV_ER_CF_G_02' => new List<String>{'Contributo Eur/gg 2','Contributo Eur/gg 2 da stampare'},
        'ZDV_ER_CF_G_03' => new List<String>{'Contributo Eur/gg 3','Contributo Eur/gg 3 da stampare'},
        'ZDV_ER_CF_G_04' => new List<String>{'Contributo Eur/gg 4','Contributo Eur/gg 4 da stampare'},
        'ZDV_ER_CF_P_01' => new List<String>{'Contributo Eur/kW 1','Contributo Eur/kW 1 da stampare'},
        'ZDV_ER_CF_P_02' => new List<String>{'Contributo Eur/kW 2','Contributo Eur/kW 2 da stampare'},
        'ZDV_ER_CF_P_03' => new List<String>{'Contributo Eur/kW 3','Contributo Eur/kW 3 da stampare'},
        'ZDV_ER_CF_P_04' => new List<String>{'Contributo Eur/kW 4','Contributo Eur/kW 4 da stampare'},
        'ZDV_ER_SE_ACON' => new List<String>{'VAS billabile',''},
        'ZDV_GR_ACONSUM' => new List<String>{'VAS billabile',''},
        'ZDV_ER_BN_3_AC' => new List<String>{'VAS sconto %','VAS sconto % da stampare'},
        'ZDV_ER_BN_2_AC' => new List<String>{'VAS sconto €/gg','VAS sconto €/gg da stampare'},
        'ZDV_GF_ESE_AC' => new List<String>{'VAS Esenzione costo servizio','VAS Esenzione costo servizio da stampare'},
        'ZDV_GF_BON_P1' => new List<String>{'Bonus Percentuale 1','Bonus Percentuale 1 da stampare'},
        'ZDV_GF_BON_P2' => new List<String>{'Bonus Percentuale 2','Bonus Percentuale 2 da stampare'},
        'ZDV_GF_BON_P3' => new List<String>{'Bonus Percentuale 3','Bonus Percentuale 3 da stampare'},
        'ZDV_GF_BON_P4' => new List<String>{'Bonus Percentuale 4','Bonus Percentuale 4 da stampare'},
        'ZDV_GP_BO_SMC1' => new List<String>{'Bonus Eur/smc 1','Bonus Eur/smc 1 da stampare'},
        'ZDV_GP_BO_SMC2' => new List<String>{'Bonus Eur/smc 2','Bonus Eur/smc 2 da stampare'},
        'ZDV_GP_BO_SMC3' => new List<String>{'Bonus Eur/smc 3','Bonus Eur/smc 3 da stampare'},
        'ZDV_GP_BO_SMC4' => new List<String>{'Bonus Eur/smc 4','Bonus Eur/smc 4 da stampare'},
        'ZDV_GR_BO_M_01' => new List<String>{'Bonus Eur/mese 1','Bonus Eur/mese 1 da stampare'},
        'ZDV_GR_BO_M_02' => new List<String>{'Bonus Eur/mese 2','Bonus Eur/mese 2 da stampare'},
        'ZDV_GR_BO_M_03' => new List<String>{'Bonus Eur/mese 3','Bonus Eur/mese 3 da stampare'},
        'ZDV_GR_BO_M_04' => new List<String>{'Bonus Eur/mese 4','Bonus Eur/mese 4 da stampare'},
        'ZDV_GP_BON_GG1' => new List<String>{'Bonus Eur/gg 1','Bonus Eur/gg 1 da stampare'},
        'ZDV_GP_BON_GG2' => new List<String>{'Bonus Eur/gg 2','Bonus Eur/gg 2 da stampare'},
        'ZDV_GP_BON_GG3' => new List<String>{'Bonus Eur/gg 3','Bonus Eur/gg 3 da stampare'},
        'ZDV_GP_BON_GG4' => new List<String>{'Bonus Eur/gg 4','Bonus Eur/gg 4 da stampare'},
        'ZDV_GP_CO_SMC1' => new List<String>{'Contributo Eur/smc 1','Contributo Eur/smc 1 da stampare'},
        'ZDV_GP_CO_SMC2' => new List<String>{'Contributo Eur/smc 2','Contributo Eur/smc 2 da stampare'},
        'ZDV_GP_CO_SMC3' => new List<String>{'Contributo Eur/smc 3','Contributo Eur/smc 3 da stampare'},
        'ZDV_GP_CO_SMC4' => new List<String>{'Contributo Eur/smc 4','Contributo Eur/smc 4 da stampare'},
        'ZDV_GR_CO_M_01' => new List<String>{'Contributo Eur/mese 1','Contributo Eur/mese 1 da stampare'},
        'ZDV_GR_CO_M_02' => new List<String>{'Contributo Eur/mese 2','Contributo Eur/mese 2 da stampare'},
        'ZDV_GR_CO_M_03' => new List<String>{'Contributo Eur/mese 3','Contributo Eur/mese 3 da stampare'},
        'ZDV_GR_CO_M_04' => new List<String>{'Contributo Eur/mese 4','Contributo Eur/mese 4 da stampare'},
        'ZDV_GP_CO_GG1' => new List<String>{'Contributo Eur/gg 1','Contributo Eur/gg 1 da stampare'},
        'ZDV_GP_CO_GG2' => new List<String>{'Contributo Eur/gg 2','Contributo Eur/gg 2 da stampare'},
        'ZDV_GP_CO_GG3' => new List<String>{'Contributo Eur/gg 3','Contributo Eur/gg 3 da stampare'},
        'ZDV_GP_CO_GG4' => new List<String>{'Contributo Eur/gg 4','Contributo Eur/gg 4 da stampare'},
        'ZDV_ER_BN_3_AC' => new List<String>{'VAS sconto %','VAS sconto % da stampare'},
        'ZDV_ER_BN_2_AC' => new List<String>{'VAS sconto €/gg','VAS sconto €/gg da stampare'},
        'ZDV_ER_BN_1_AC' => new List<String>{'VAS Esenzione costo servizio','VAS Esenzione costo servizio da stampare'},
        'ZDV_GF_SCN_PAC' => new List<String>{'VAS sconto %','VAS sconto % da stampare'},
        'ZDV_GP_SC_GGAC' => new List<String>{'VAS sconto €/gg','VAS sconto €/gg da stampare'},
        'ZDV_GF_ESE_AC' => new List<String>{'VAS Esenzione costo servizio','VAS Esenzione costo servizio da stampare'}        
    };
}