public inherited sharing class HDT_UTL_QuoteManagement {

    @InvocableMethod
    public static List<QuoteManagement__c> addRequiredInformation(List<HDT_UTL_FlowInputs> inputs){
		System.debug('dentro classe' + inputs);
		
		List<QuoteManagement__c> toReturnQuoteManagement = new List<QuoteManagement__c>();
        String processType = inputs[0].processType;
		
		if(processType != null && processType.equalsIgnoreCase('Verifiche')){
            
            toReturnQuoteManagement = menageVerifiche(inputs);
			
		}else if(processType != null && processType.equalsIgnoreCase('Preventivi')){
            
            toReturnQuoteManagement = menagePreventivi(inputs);
            
        }

		return toReturnQuoteManagement;
    }
	
	private static List<QuoteManagement__c> menageVerifiche(List<HDT_UTL_FlowInputs> inputs){
		String operationType = inputs[0].operationtype;
        String commodity = inputs[0].commodity;
		return HDT_QR_QuoteManagement.queryAddInformation(commodity, operationType);
	}
	
	private static List<QuoteManagement__c> menagePreventivi(List<HDT_UTL_FlowInputs>  inputs){

		String localDispatcher 		= inputs[0].localDispatcher; 
		String seller 				= inputs[0].seller;
		String voltage 				= inputs[0].voltage;
		Double powerAvailable 		= inputs[0].powerAvailable != '' ? Double.valueOf(inputs[0].powerAvailable) : null;
		Double powerCommitted 		= inputs[0].powerCommitted != '' ? Double.valueOf(inputs[0].powerCommitted) : null;
		String connectionType 		= inputs[0].connectionType;
		Double powerRequested 		= inputs[0].powerRequested != '' ? Double.valueOf(inputs[0].powerRequested) : null;
		String supplyType 			= inputs[0].supplyType;
		String phaseType 			= inputs[0].phaseType;
		String energyUseType		= inputs[0].energyUseType;
		String displacementDistance	= inputs[0].displacementDistance;
		String operationType 		= inputs[0].operationtype;
        String commodity 			= inputs[0].commodity;
		String caliber 				= inputs[0].caliber;
		Boolean isInrete 			= checkLocalDispatcher(localDispatcher);
		Boolean powerAdjustment 	= true;
		String vendDist = isInrete ? 'InRete' : 'ExtraRete';
		String checkPrPc = '';
		String rangePr = '';
		String rangePc = '';
		if(powerRequested != null && powerAvailable != null &&  powerRequested * (1.1) < powerAvailable){
			powerAdjustment = false;
		}
		if(powerRequested != null && powerCommitted != null ){
			if(powerRequested > powerCommitted){
				checkPrPc = 'MAG';
			}else if (powerRequested < powerCommitted){
				checkPrPc = 'MIN';
			}else{
				checkPrPc = 'UGUALE';
			}
		}
		rangePr = getRangeValue(powerRequested);
		rangePc = getRangeValue(powerCommitted);
		
		String conditions = '(AdegPotDisp__c =' + powerAdjustment + ' OR AdegPotDisp__c = null) AND (Caliber__c = \''+ caliber + '\' OR Caliber__c = null) AND (ComparePotRi__c = \'' + checkPrPc + '\' OR ComparePotRi__c = null) AND (RequestedPhase__c = \''+ phaseType + '\' OR RequestedPhase__c = null) AND (PowerEngaged__c = \'' + rangePc + '\' OR PowerEngaged__c = null) AND (PowerRequired__c = \'' + rangePr + '\' OR PowerRequired__c = null) AND (GdmMovement__c = \'' + displacementDistance + '\' or GdmMovement__c = null) AND (VoltageRequired__c = \'' + voltage + '\' OR VoltageRequired__c = null) AND (ConnectionType__c = \'' + connectionType + '\' OR ConnectionType__c = null) AND Operation_type__c = \'' + operationType + '\' AND Commodity__c = \'' + commodity + '\' AND (EnergyUseType__c = \'' + energyUseType + '\' OR EnergyUseType__c = null) AND (VendDist__c = \'' + vendDist + '\' OR VendDist__c = null)';
		String fields = 'Id,CausalCode__c, QuoteType__c,OperationCode__c';
		
		return HDT_QR_QuoteManagement.queryString(fields, conditions);

	}
	
	private static boolean checkLocalDispatcher(String localDispatcher){
		if(localDispatcher != null && String.isNotBlank(localDispatcher)){
			Integer dispatcherList = [SELECT COUNT() FROM HDT_LocalDispatcherInrete__mdt WHERE DispatcherDesc__c =: localDispatcher];
			if(dispatcherList != null && dispatcherList > 0){
				return true;
			}else{
				return false;
			}
		}
		return false;
    }
    
	private static String getRangeValue(Double power){
		String result = '';
		if(power != null){
			List<HDT_PowerRangeValue__mdt> powerRangeValueList = [SELECT Range__c FROM HDT_PowerRangeValue__mdt WHERE Low__c <=: power AND High__c >= :power WITH SECURITY_ENFORCED];
			if(powerRangeValueList.size() > 0){
				result = powerRangeValueList[0].Range__c;
			}
		}

        return result;

	}
	
	private static String check;
	
    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String processType;

        @InvocableVariable
        public String commodity;

        @InvocableVariable
        public String operationtype;

        @InvocableVariable
        public String caliber;
		
		@InvocableVariable
        public String localDispatcher;
		
		@InvocableVariable
        public String seller;
		
		@InvocableVariable
        public String voltage;
		
		@InvocableVariable
        public String powerAvailable;
		
		@InvocableVariable
        public String powerCommitted;
		
		@InvocableVariable
        public String connectionType;
		
		@InvocableVariable
        public String powerRequested;
		
		@InvocableVariable
        public String supplyType;
		
		@InvocableVariable
        public String phaseType;
		
		@InvocableVariable
        public String energyUseType;
		
		@InvocableVariable
        public String displacementDistance;
    }
    

}