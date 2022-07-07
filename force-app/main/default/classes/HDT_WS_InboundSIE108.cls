@RestResource(urlMapping='/SIE108InboundServices/*')
global with sharing class HDT_WS_InboundSIE108 {
    
    @HttpGet
    global static List<HDT_WRP_SIE108OrderEnrichment> getSIE108SingleOrder() {
        RestRequest req = RestContext.request;
        String orderId  = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<HDT_WRP_SIE108OrderEnrichment> response = new List<HDT_WRP_SIE108OrderEnrichment>();
        HDT_WRP_SIE108OrderEnrichment responseItem = mapOutputResponse(orderId);
        response.add(responseItem);
        return response;
    }

    @HttpPost
    global static List<HDT_WRP_SIE108OrderEnrichment> doPostSIE108ListOrder(List<String> orderList)  {
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
            List<String> positionsInFile = SIE108MAPPINGFIELDS.get(element.field);
            if(positionsInFile != null ){                
                responseItem.orderEnrichmentList.add(new HDT_WRP_SIE108OrderEnrichment.HDT_WRP_SIE108Positions(positionsInFile[0], element.value?.substringBeforeLast('_')));
                responseItem.orderEnrichmentList.add(new HDT_WRP_SIE108OrderEnrichment.HDT_WRP_SIE108Positions(positionsInFile[1], element.value?.substringAfterLast('_')));
            }          
        }
       return responseItem;
    }

    // Map from operands to SIE108 file columns
    private static Map<String,List<String>> SIE108MAPPINGFIELDS = new Map<String,List<String>>{
        'ZDV_ER_BN_P_01' => new List<String>{'EE_Bonus_Percentule1','EE_Versione_Bonus_perc1'},
        'ZDV_ER_BN_P_02' => new List<String>{'EE_Bonus_Percentule2','EE_Versione_Bonus_perc2'},
        'ZDV_ER_BN_P_03' => new List<String>{'EE_Bonus_Percentule3','EE_Versione_Bonus_perc3'},
        'ZDV_ER_BN_P_04' => new List<String>{'EE_Bonus_Percentule4','EE_Versione_Bonus_perc4'},
        'ZDV_ER_BN_G_01' => new List<String>{'EE_Bonus_Eur_gg1','EE_Versione_Bonus_Eur_gg1'},
        'ZDV_ER_BN_G_02' => new List<String>{'EE_Bonus_Eur_gg2','EE_Versione_Bonus_Eur_gg2'},
        'ZDV_ER_BN_G_03' => new List<String>{'EE_Bonus_Eur_gg3','EE_Versione_Bonus_Eur_gg3'},
        'ZDV_ER_BN_G_04' => new List<String>{'EE_Bonus_Eur_gg4','EE_Versione_Bonus_Eur_gg4'},
        'ZDV_ER_BN_M_01' => new List<String>{'EE_Bonus_Eur_Mese1','EE_Versione_Bonus_mese1'},
        'ZDV_ER_BN_M_02' => new List<String>{'EE_Bonus_Eur_Mese2','EE_Versione_Bonus_mese2'},
        'ZDV_ER_BN_M_03' => new List<String>{'EE_Bonus_Eur_Mese3','EE_Versione_Bonus_mese3'},
        'ZDV_ER_BN_M_04' => new List<String>{'EE_Bonus_Eur_Mese4','EE_Versione_Bonus_mese4'},
        'ZDV_ER_BN_V_01' => new List<String>{'EE_Bonus_Eur_kWh1','EE_Versione_Bonus_kWh1'},
        'ZDV_ER_BN_V_02' => new List<String>{'EE_Bonus_Eur_kWh2','EE_Versione_Bonus_kWh2'},
        'ZDV_ER_BN_V_03' => new List<String>{'EE_Bonus_Eur_kWh3','EE_Versione_Bonus_kWh3'},
        'ZDV_ER_BN_V_04' => new List<String>{'EE_Bonus_Eur_kWh4','EE_Versione_Bonus_kWh4'},
        'ZDV_ER_CF_V_01' => new List<String>{'EE_Contributo_Eur_kWh1','EE_Versione_Contr_kWh1'},
        'ZDV_ER_CF_V_02' => new List<String>{'EE_Contributo_Eur_kWh2','EE_Versione_Contr_kWh2'},
        'ZDV_ER_CF_V_03' => new List<String>{'EE_Contributo_Eur_kWh3','EE_Versione_Contr_kWh3'},
        'ZDV_ER_CF_V_04' => new List<String>{'EE_Contributo_Eur_kWh4','EE_Versione_Contr_kWh4'},
        'ZDV_ER_CF_M_01' => new List<String>{'EE_Contributo_Eur_mese1','EE_Versione_Contr_mese1'},
        'ZDV_ER_CF_M_02' => new List<String>{'EE_Contributo_Eur_mese2','EE_Versione_Contr_mese2'},
        'ZDV_ER_CF_M_03' => new List<String>{'EE_Contributo_Eur_mese3','EE_Versione_Contr_mese3'},
        'ZDV_ER_CF_M_04' => new List<String>{'EE_Contributo_Eur_mese4','EE_Versione_Contr_mese4'},
        'ZDV_ER_CF_G_01' => new List<String>{'EE_Contributo_Eur_gg1','EE_Versione_Contr_gg1'},
        'ZDV_ER_CF_G_02' => new List<String>{'EE_Contributo_Eur_gg2','EE_Versione_Contr_gg2'},
        'ZDV_ER_CF_G_03' => new List<String>{'EE_Contributo_Eur_gg3','EE_Versione_Contr_gg3'},
        'ZDV_ER_CF_G_04' => new List<String>{'EE_Contributo_Eur_gg4','EE_Versione_Contr_gg4'},
        'ZDV_ER_CF_P_01' => new List<String>{'EE_Contributo_Eur_kW1','EE_Versione_Contr_kW1'},
        'ZDV_ER_CF_P_02' => new List<String>{'EE_Contributo_Eur_kW2','EE_Versione_Contr_kW2'},
        'ZDV_ER_CF_P_03' => new List<String>{'EE_Contributo_Eur_kW3','EE_Versione_Contr_kW3'},
        'ZDV_ER_CF_P_04' => new List<String>{'EE_Contributo_Eur_kW4','EE_Versione_Contr_kW4'},
        'ZDV_GF_BON_P1' => new List<String>{'Gas_Bonus_Percentuale1','Gas_Versione_Bonus_perc1'},
        'ZDV_GF_BON_P2' => new List<String>{'Gas_Bonus_Percentuale2','Gas_Versione_Bonus_perc2'},
        'ZDV_GF_BON_P3' => new List<String>{'Gas_Bonus_Percentuale3','Gas_Versione_Bonus_perc3'},
        'ZDV_GF_BON_P4' => new List<String>{'Gas_Bonus_Percentuale4','Gas_Versione_Bonus_perc4'},
        'ZDV_GP_BO_SMC1' => new List<String>{'Gas_Bonus_Eur_smc1','Gas_Versione_bonus_smc1'},
        'ZDV_GP_BO_SMC2' => new List<String>{'Gas_Bonus_Eur_smc2','Gas_Versione_bonus_smc2'},
        'ZDV_GP_BO_SMC3' => new List<String>{'Gas_Bonus_Eur-smc3','Gas_Versione_bonus_smc3'},
        'ZDV_GP_BO_SMC4' => new List<String>{'Gas_Bonus_Eur_smc4','Gas_Versione_bonus_smc4'},
        'ZDV_GR_BO_M_01' => new List<String>{'Gas_Bonus_Eur_mese1','Gas_Versione_bonus_mese1'},
        'ZDV_GR_BO_M_02' => new List<String>{'Gas_Bonus_Eur_mese2','Gas_Versione_bonus_mese2'},
        'ZDV_GR_BO_M_03' => new List<String>{'Gas_Bonus_Eur_mese3','Gas_Versione__bonus_mese3'},
        'ZDV_GR_BO_M_04' => new List<String>{'Gas_Bonus_Eu_mese4','Gas_Versione_bonus_mese4'},
        'ZDV_GP_BON_GG1' => new List<String>{'Gas_Bonus_Eur_gg1','Gas_Versione_Bonus_gg1'},
        'ZDV_GP_BON_GG2' => new List<String>{'Gas_Bonus_Eur_gg2','Gas_Versione_Bonus_gg2'},
        'ZDV_GP_BON_GG3' => new List<String>{'Gas_Bonus_Eur_gg3','Gas_Versione_Bonus_gg3'},
        'ZDV_GP_BON_GG4' => new List<String>{'Gas_Bonus_Eur_gg4','Gas_Versione_Bonus_gg4'},
        'ZDV_GP_CO_SMC1' => new List<String>{'Gas_Contributo_Eur_smc1','Gas_Versione_Contr_smc1'},
        'ZDV_GP_CO_SMC2' => new List<String>{'Gas_Contributo_Eur_smc2','Gas_Versione_Contr_smc2'},
        'ZDV_GP_CO_SMC3' => new List<String>{'Gas_Contributo_Eur_smc3','Gas_Versione_Contr_smc3'},
        'ZDV_GP_CO_SMC4' => new List<String>{'Gas_Contributo_Eur_smc4','Gas_Versione_Contr_smc4'},
        'ZDV_GR_CO_M_01' => new List<String>{'Gas_Contributo_Eur_mese1','Gas_Versione_Contr_mese1'},
        'ZDV_GR_CO_M_02' => new List<String>{'Gas_Contributo_Eur_mese2','Gas_Versione_Contr_mese2'},
        'ZDV_GR_CO_M_03' => new List<String>{'Gas_Contributo_Eur_mese3','Gas_Versione_Contr_mese3'},
        'ZDV_GR_CO_M_04' => new List<String>{'Gas_Contributo_Eur_mese4','Gas_Versione_Contr_mese4'},
        'ZDV_GP_CO_GG1' => new List<String>{'Gas_Contributo_Eur_gg1','Gas_Versione_Contr_gg1'},
        'ZDV_GP_CO_GG2' => new List<String>{'Gas_Contributo_Eur_gg2','Gas_Versione_Contr_gg2'},
        'ZDV_GP_CO_GG3' => new List<String>{'Gas_Contributo_Eur_gg3','Gas_Versione_Contr_gg3'},
        'ZDV_GP_CO_GG4' => new List<String>{'Gas_Contributo_Eur_gg4','Gas_Versione_Contr_gg4'},
        'ZDV_ER_BN_3_AC' => new List<String>{'VAS_nome_Sconto_perc','VAS_versione_Sconto_perc'},
        'ZDV_ER_BN_2_AC' => new List<String>{'VAS_nome_Sconto_euro','VAS_versione_Sconto_euro'},
        'ZDV_ER_BN_1_AC' => new List<String>{'VAS_nome_esenzione','VAS_versione_esenzione'},
        'ZDV_GF_SCN_PAC' => new List<String>{'GAS_VAS_nome_Sconto_perc','GAS_VAS_versione_Sconto_perc'},
        'ZDV_GP_SC_GGAC' => new List<String>{'GAS_VAS_nome_Sconto_euro','GAS_VAS_versione_Sconto_euro'},
        'ZDV_GF_ESE_AC' => new List<String>{'GAS_VAS_nome_esenzione','GAS_VAS_versione_esenzione'},
        'ZDV_ER_SE_ACON' => new List<String>{'VAS_Analisi_consumi','Versione_VAS_Analisi_consumi'},
        'ZDV_GR_ACONSUM' => new List<String>{'GAS_VAS_Analisi_consumi','Vers_GAS_VAS_Analisi_consumi'}
    };
}