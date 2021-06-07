public with sharing class HDT_UTL_ServicePoint {
    private static HDT_QR_Account accountQr = new HDT_QR_Account();
    public HDT_UTL_ServicePoint() {

    }


    @AuraEnabled
	public static List<ServicePoint__c> extractDataFromArriccDataServiceWithExistingSp(ServicePoint__c sp, HDT_WS_ArrichmentDataEntityResponse response ){
		
			servicePoint__c spNew = new servicePoint__c();
			if(sp!= null){
				system.debug('entra in sp diverso da null' + sp);
				spNew = sp;
			}
		Map<string,string> mapRes = new Map<string,string>();
		system.debug('posizioni ***************************'+response.data.posizioni[0]);
	
			for(HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_posizioniResponseObject r : response.data.posizioni){
				if(!String.isBlank(r.campo) && mapRes.get(r.campo.toUpperCase()) == null){
					system.debug('campo ****' + r.campo);
					system.debug('valore ****' + r.valore);
					mapRes.put(r.campo.toUpperCase(),r.valore);
				}
	
			}

		
					
	/*	if(mapRes.get('CALIBRO1')!=null && !String.isBlank(mapRes.get('CALIBRO1'))){
			spNew.MeterClass__c = mapRes.get('CALIBRO1');
		}
		if(mapRes.get('CODICEREMI')!=null && !String.isBlank(mapRes.get('CODICEREMI'))){
			spNew.RemiCode__c = mapRes.get('CODICEREMI');
		}

		if(mapRes.get('CONTRATTO')!=null && !String.isBlank(mapRes.get('CONTRATTO'))){
			spNew.TemporaryContractCode__c = mapRes.get('CONTRATTO');
		}

	/*	if(mapRes.get('CONTRATTO')!=null && !String.isBlank(mapRes.get('CONTRATTO'))){
			spNew.Disconnectable__c = mapRes.get('CONTRATTO');
		}*/

		/*if(mapRes.get('FASE')!=null && !String.isBlank(mapRes.get('FASE'))){
			spNew.RequestPhase__c  = mapRes.get('FASE');
		}
*/
		if(mapRes.get('PRESSIONE')!=null && !String.isBlank(mapRes.get('PRESSIONE'))){
			spNew.Pressure__c  = integer.valueOf(mapRes.get('PRESSIONE'));
		}

		if(mapRes.get('CODICEREMI')!=null && !String.isBlank(mapRes.get('CODICEREMI'))){
			spNew.RemiCode__c = mapRes.get('CODICEREMI');
		}
        if(mapRes.get('CALIBRO1')!=null && !String.isBlank(mapRes.get('CALIBRO1'))){
			//spNew.MeterClass__c = mapRes.get('CALIBRO1') == 'GRT003' ? 'G4' : 'G6' ;
           if(mapRes.get('CALIBRO1')=='GRT005'){
            spNew.MeterClass__c = 'G10';

           }
           if(mapRes.get('CALIBRO1')=='GRT010'){
            spNew.MeterClass__c = 'G100';
            
           }
           if(mapRes.get('CALIBRO1')=='GRT015'){
            spNew.MeterClass__c = 'G100';
            
           }
           if(mapRes.get('CALIBRO1')=='GRT006'){
            spNew.MeterClass__c = 'G16';
            
           }
           if(mapRes.get('CALIBRO1')=='GRT011'){
            spNew.MeterClass__c = 'G160';
            
           }
           if(mapRes.get('CALIBRO1')=='GRT016'){
            spNew.MeterClass__c = 'G1600';
            
           }
           if(mapRes.get('CALIBRO1')=='GRT002'){
            spNew.MeterClass__c = 'G2,5';
            
           }
           if(mapRes.get('CALIBRO1')=='GRT007'){
            spNew.MeterClass__c = 'G25';
            
           }
           if(mapRes.get('CALIBRO1')=='GRT012'){
            spNew.MeterClass__c = 'G250';
           }
           if(mapRes.get('CALIBRO1')=='GRT003'){
            spNew.MeterClass__c = 'G4';
           }
           if(mapRes.get('CALIBRO1')=='GRT008'){
            spNew.MeterClass__c = 'G40';
           }
           if(mapRes.get('CALIBRO1')=='GRT013'){
            spNew.MeterClass__c = 'G400';
           }
           if(mapRes.get('CALIBRO1')=='GRT017'){
            spNew.MeterClass__c = 'G4000';
           }
           if(mapRes.get('CALIBRO1')=='GRT004'){
            spNew.MeterClass__c = 'G6';
           }
           if(mapRes.get('CALIBRO1')=='GRT009'){
            spNew.MeterClass__c = 'G65';
           }
           if(mapRes.get('CALIBRO1')=='GRT014'){
            spNew.MeterClass__c = 'G650';
           }
           if(mapRes.get('CALIBRO1')=='GRT018'){
            spNew.MeterClass__c = 'G6500';
           }

		}
        if(mapRes.get('MATRICOLA1')!=null && !String.isBlank(mapRes.get('MATRICOLA1'))){
			spNew.MeterSN__c = mapRes.get('MATRICOLA1');
		}
        if(mapRes.get('BRANDSOCIETARIO')!=null && !String.isBlank(mapRes.get('BRANDSOCIETARIO'))){
			spNew.BrandLogo__c   = mapRes.get('BRANDSOCIETARIO');
		}


				//campi fornitura
				if(mapRes.get('DISTRIBUTORE')!=null && !String.isBlank(mapRes.get('DISTRIBUTORE'))){
					//spNew.Account__r.id =mapRes.get('DISTRIBUTORE') ;
                    Account a = accountQr.getAccountByDistributorKey(mapRes.get('DISTRIBUTORE'));
                    spNew.Distributor__c = a.id;
                    System.debug('SOLILLO');
				}
				if(mapRes.get('POD')!=null && !String.isBlank(mapRes.get('POD'))){
					spNew.ServicePointCode__c   = mapRes.get('POD');
                    spNew.Name   = mapRes.get('POD');


				}
				if(mapRes.get('DESCRCOMM')!=null && !String.isBlank(mapRes.get('DESCRCOMM'))){
				
                    if(mapRes.get('DESCRCOMM')== 'Energia elettrica'){
                        spNew.CommoditySector__c = 'Energia Elettrica';

                    }else
                    {
					    spNew.CommoditySector__c = 'Gas';
                    }
		
				}
                if(mapRes.get('MOTGARANZIAFORN')==null){
				
                    spNew.Disconnectable__c = 'Si';
				}
                else if (mapRes.get('MOTGARANZIAFORN') == ''){
				
                    spNew.Disconnectable__c = 'No';
				}

				if(mapRes.get('IMPIANTO')!=null && !String.isBlank(mapRes.get('IMPIANTO'))){
		
					spNew.SAPImplantCode__c = mapRes.get('IMPIANTO');
				}
				if(mapRes.get('TIPOIMPIANTO')!=null && !String.isBlank(mapRes.get('TIPOIMPIANTO'))){
		
					spNew.ImplantType__c  = mapRes.get('TIPOIMPIANTO')+'-'+mapRes.get('DESCRTIPOIMP');		
				}
				if(mapRes.get('CONSUMOCAPDR')!=null && !String.isBlank(mapRes.get('CONSUMOCAPDR'))){
		
					spNew.AnnualConsumption__c = integer.valueOf(mapRes.get('CONSUMOCAPDR'));
				}
                if(mapRes.get('CONSUMOANNUOEE')!=null && !String.isBlank(mapRes.get('CONSUMOANNUOEE'))){
		
					spNew.AnnualConsumption__c = integer.valueOf(mapRes.get('CONSUMOANNUOEE'));
				}
				if(mapRes.get('MERCATO')!=null && !String.isBlank(mapRes.get('MERCATO'))){
                    String mercato = mapRes.get('MERCATO').substring(0,1) + mapRes.get('MERCATO').substring(1,mapRes.get('MERCATO').length()).toLowerCase();
					spNew.MarketOrigin__c = mercato;
				}
				if(mapRes.get('FLAGTELEGESTIBILE')!=null && !String.isBlank(mapRes.get('FLAGTELEGESTIBILE'))){
		
					spNew.IsRemoteManaged__c = 'X'.equalsIgnoreCase(mapRes.get('FLAGTELEGESTIBILE'));
				}
				if(mapRes.get('POTENZACONTRATTUALE')!=null && !String.isBlank(mapRes.get('POTENZACONTRATTUALE'))){
					//spNew.PowerContractual__c = integer.valueOf(mapRes.get('POTENZACONTRATTUALE').subString(0,mapRes.get('POTENZACONTRATTUALE').indexOf('.')+1));
                    Decimal d = integer.valueOf(mapRes.get('POTENZATECNICA'));
                    System.debug('POTENZACONTRATTUALE****************' + mapRes.get('POTENZACONTRATTUALE'));
                    spNew.PowerContractual__c = d.setScale(0);
                    System.debug('POTENZACONTRATTUALE2****************' + spNew.PowerContractual__c );
				}
				if(mapRes.get('POTENZATECNICA')!=null && !String.isBlank(mapRes.get('POTENZATECNICA'))){

                    System.debug('POTENZATECNICA1****************' + mapRes.get('POTENZATECNICA'));
                    
                    Decimal d = integer.valueOf(mapRes.get('POTENZATECNICA'));
                    //spNew.PowerAvailable__c  =integer.valueOf(mapRes.get('POTENZATECNICA').subString(0,mapRes.get('POTENZATECNICA').indexOf('.'))) ;
                    spNew.PowerAvailable__c  =d.setScale(1);

                    System.debug('POTENZATECNICA****************' + d.setScale(1));

				}
				if(mapRes.get('TENSIONE')!=null && !String.isBlank(mapRes.get('TENSIONE'))){
		
					spNew.VoltageLevel__c = mapRes.get('TENSIONE');
				}
				if(mapRes.get('RESIDENTEINDFORN')!=null && !String.isBlank(mapRes.get('RESIDENTEINDFORN'))){
		
					spNew.Resident__c = mapRes.get('RESIDENTEINDFORN') == 'SI' ? true : false;
				}

				//campi indirizzo
				if(mapRes.get('CAP')!=null && !String.isBlank(mapRes.get('CAP'))){

					spNew.SupplyPostalCode__c = mapRes.get('CAP');
				}
				if(mapRes.get('VIA')!=null && !String.isBlank(mapRes.get('VIA'))){
					spNew.SupplyStreet__c  = mapRes.get('VIA');
				}
				if(mapRes.get('TIPOVIA')!=null && !String.isBlank(mapRes.get('TIPOVIA'))){
					spNew.SupplyStreetToponym__c  = mapRes.get('TIPOVIA');
				}
				if(mapRes.get('CIVICO')!=null && !String.isBlank(mapRes.get('CIVICO'))){
					spNew.SupplyStreetNumber__c  = mapRes.get('CIVICO');
				}
				if(mapRes.get('LOCALITA')!=null && !String.isBlank(mapRes.get('LOCALITA'))){
					spNew.SupplyCity__c  = mapRes.get('LOCALITA');
				}
				if(mapRes.get('CODICEVIA')!=null && !String.isBlank(mapRes.get('CODICEVIA'))){
					spNew.SupplySAPStreetCode__c = mapRes.get('CODICEVIA');
				}
                if(mapRes.get('REGIONE')!=null && !String.isBlank(mapRes.get('REGIONE'))){
					spNew.SupplyProvince__c = mapRes.get('REGIONE');
				}
				if(mapRes.get('CODIFICALOCALITA')!=null && !String.isBlank(mapRes.get('CODIFICALOCALITA'))){
					spNew.SupplySAPCityCode__c = mapRes.get('CODIFICALOCALITA');
				}
                if(mapRes.get('CODICEPAESE')!=null && !String.isBlank(mapRes.get('CODICEPAESE'))){
					spNew.SupplyCountry__c = mapRes.get('CODICEPAESE') == 'IT' ? 'Italia' : 'Estero';
				}


		system.debug('spNew*****************' + spNew);
		List<ServicePoint__c> servicePoints = new List<ServicePoint__c>();
		servicePoints.add(spNew);
		return servicePoints;
	}

    @AuraEnabled
    public static List<String> objectToList(HDT_WRP_AddressObject Wrap){
        System.debug('HDT_UTL_ServicePoint objectToList START');

        List<String> listFields = new List<String>();
        String stringWrap = JSON.serialize(Wrap);
        listFields = (List<String>)JSON.deserializeUntyped(stringWrap);

        System.debug('HDT_UTL_ServicePoint objectToList END');
        return listFields;

    }
 

    @AuraEnabled(cacheable=true)
    public static  HDT_WRP_AddressObject getInstanceWrapAddressObject(sObject s){
    System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject START');

    Map<String,String> mapApiName = new map<String,String>{	
        'SupplyPostalCode__c' => 'CAP',
        'SupplyStreetNumber__c' => 'Civico',
        'SupplyCountry__c' => 'Stato',
        'SupplySAPCityCode__c' => 'CodiceComuneSAP',
        'SupplyCity__c' => 'Comune',
        'SupplyStreet__c' => 'Via',
        'SupplyStreetNumberExtension__c' => 'EstensCivico',
        'SupplySAPStreetCode__c' => 'CodiceViaStradarioSAP',
        'SupplyIsAddressVerified__c' => 'IndirizzoVerificato',
        'SupplyProvince__c' => 'Provincia',
        'SupplyIsAddressVerified__c' => 'FlagVerificato',
        'SupplyPlace__c' => 'Localita',
        'SupplyPlaceCode__c' => 'CodiceLocalita'
        };

   
    HDT_WRP_AddressObject result = new HDT_WRP_AddressObject();

    if(s!= null){
        System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject END');
        List<sObject> listObject = new  List<sObject>();
        listObject.add((sObject)s);
        String type = listObject.get(0).getSObjectType().getDescribe().getName();
        Map<String,Boolean> mapBooleanObject = new Map<String,Boolean>();
        Map<String,String> mapObject = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
    
        for (String fieldName: fieldMap.keySet()) 
        {
            //System.debug('Field API Name='+fieldName+'label :'+fieldMap.get(fieldName).getDescribe().getLabel());
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            if(fielddataType.name().toUpperCase() == 'STRING' || fielddataType.name().toUpperCase() == 'TEXTAREA'|| fielddataType.name().toUpperCase() == 'TEXT')
            {
                mapObject.put(fieldMap.get(fieldName).getDescribe().getName(),(String)(s.get(fieldName)));
            }
            if(fielddataType.name().toUpperCase() == 'BOOLEAN'||fielddataType.name().toUpperCase() == 'CHECKBOX' ){
                mapBooleanObject.put(fieldMap.get(fieldName).getDescribe().getName(),(Boolean)(s.get(fieldName)));
            }                
        }
        system.debug('mapObject*************'+mapObject);
        system.debug('mapBooleanObject*************'+mapBooleanObject);
        return  result =   mapFieldsAddressWithWrapObject(mapObject,mapBooleanObject,mapApiName);

    }else{     
    
        result = new HDT_WRP_AddressObject('','','','','','','','','',false,false,'','');
        System.debug('result:' +  result);
    }

	
    System.debug('HDT_UTL_ServicePoint - getInstanceWrapAddressObject END');
    return result;
    }
	
	
	
	@AuraEnabled(cacheable=true)
    public static HDT_WRP_AddressObject mapFieldsAddressWithWrapObject(Map<String,String> mapObject,Map<String,Boolean> mapBooleanObject,Map<String,String> mapApiName){
        System.debug('HDT_UTL_ServicePoint - mapFieldsAddressWithWrapObject START');
        HDT_WRP_AddressObject h = new HDT_WRP_AddressObject();
		
		if(!mapObject.isEmpty()){
            for(String s :mapObject.keySet()){
                system.debug('stringa *****************' + s);
                
                if(mapApiName.containsKey(s) && s == 'SupplyPostalCode__c'){
                    System.debug('CAP :' + mapObject.get(s));
                    h.CAP = mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyCity__c'){
                    System.debug('Comune :' + mapObject.get(s));
                    h.Comune= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyStreet__c'){
                    System.debug('Via :' + mapObject.get(s));
                    h.Via= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyStreetNumber__c'){
                    System.debug('Civico :' + mapObject.get(s));
                    h.Civico= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyStreetNumberExtension__c'){
                    System.debug('EstensCivico :' + mapObject.get(s));
                    h.EstensCivico= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyProvince__c'){
                    System.debug('Provincia :' + mapObject.get(s));
                    h.Provincia= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyCountry__c'){
                    System.debug('Stato :' + mapObject.get(s));
                    h.Stato= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplySAPCityCode__c'){
                    System.debug('CodiceComuneSAP :' + mapObject.get(s));
                    h.CodiceComuneSAP= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplySAPStreetCode__c'){
                    System.debug('CodiceViaStradarioSAP :' + mapObject.get(s));
                    h.CodiceViaStradarioSAP= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplySAPStreetCode__c'){
                    System.debug('CodiceViaStradarioSAP :' + mapObject.get(s));
                    h.CodiceViaStradarioSAP= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyPlace__c'){
                    System.debug('Localita :' + mapObject.get(s));
                    h.Localita= mapObject.get(s);
                }
                if(mapApiName.containsKey(s) && s == 'SupplyPlaceCode__c'){
                    System.debug('Codice Localita :' + mapObject.get(s));
                    h.CodiceLocalita= mapObject.get(s);
                }
            }
        }
    

        if(!mapBooleanObject.isEmpty())
        {
            for(String b :mapBooleanObject.keySet())
            {
                if(mapApiName.containsKey(b)&& b == 'SupplyIsAddressVerified__c')
                {
                    System.debug('flagVerificato :' + mapBooleanObject.get(b));
                    h.flagVerificato= mapBooleanObject.get(b);
                }
            }
        }
        system.debug('wrapObject: ***************' + h);

          
        System.debug('HDT_UTL_ServicePoint - mapFieldsAddressWithWrapObject END');
        return h;
        
    }
}