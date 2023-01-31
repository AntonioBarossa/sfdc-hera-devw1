public inherited sharing class HDT_UTL_QuoteManagement {

	//DATA
	private static String check;
	
	
	//METODI
    @InvocableMethod
    public static List<QuoteManagement__c> addRequiredInformation(List<HDT_UTL_FlowInputs> inputs){
		//System.debug('dentro classe' + inputs);
		
		List<QuoteManagement__c> toReturnQuoteManagement = new List<QuoteManagement__c>();
		QuoteManagement__c quoteManagement = new QuoteManagement__c();
        String processType = inputs[0].processType;
		
		if(processType != null && processType.equalsIgnoreCase('Verifiche')){
            
            quoteManagement = menageVerifiche(inputs);
			
		}else if(processType != null && processType.equalsIgnoreCase('Preventivi')){
            
            quoteManagement = menagePreventivi(inputs);
            
        }

		toReturnQuoteManagement.add(quoteManagement);

		return toReturnQuoteManagement;
    }
	
	private static QuoteManagement__c menageVerifiche(List<HDT_UTL_FlowInputs> inputs){
		String operationType = inputs[0].operationtype;
        String commodity = inputs[0].commodity;
		String subprocess = inputs[0].subprocess;
		return HDT_QR_QuoteManagement.queryAddInformation(commodity, operationType,subprocess);
	}
	
	@SuppressWarnings('PMD.CyclomaticComplexity')
	private static QuoteManagement__c menagePreventivi(List<HDT_UTL_FlowInputs>  inputs){

		//@frpanico unused variables seller, supplyType fix

		string seller;
		string supplyType;

		String localDispatcher 		= inputs[0].localDispatcher; 
		seller 						= inputs[0].seller;
		String voltage 				= inputs[0].voltage;
		Decimal powerAvailable 		= inputs[0].powerAvailable;
		Decimal powerCommitted 		= inputs[0].powerCommitted;
		String connectionType 		= inputs[0].connectionType;
		Decimal powerRequested 		= inputs[0].powerRequested;
		supplyType 					= inputs[0].supplyType;
		String phaseType 			= inputs[0].phaseType;
		String energyUseType		= inputs[0].energyUseType;
		String displacementDistance	= inputs[0].displacementDistance;
		String operationType 		= inputs[0].operationtype;
        String commodity 			= inputs[0].commodity;
		String caliber 				= inputs[0].caliber;
		String voltageAvilable    	= inputs[0].voltageAvailable;
		String phaseAvaillable    	= inputs[0].phaseAvalaible;
		String subprocess    		= inputs[0].subprocess;
		Boolean isInrete 			= checkLocalDispatcher(localDispatcher);
		String powerAdjustment 	= 'Y';
		String vendDist = isInrete ? 'InRete' : 'ExtraRete';
		String checkPrPc = '';
		String rangePr = '';
		String rangePc = '';
		String voltagePhase = '';
		String connectionTypeCondition = '';
		if(powerRequested != null && powerAvailable != null &&  powerRequested * (1.1) < powerAvailable){
			powerAdjustment = 'N';
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
		if(String.isNotBlank(voltageAvilable)){
			if(String.isNotBlank(phaseAvaillable)){
				voltagePhase = voltageAvilable + '_' + phaseAvaillable.substring(0,1);
			}else {
				voltagePhase = voltageAvilable;
			}
		}
		if(operationType.equalsIgnoreCase('Variazione Potenza') && String.isNotBlank(connectionType) && connectionType.equalsIgnoreCase('Temporanea')){
			connectionTypeCondition = 'AND ConnectionType__c = \'' + String.escapeSingleQuotes(connectionType) + '\' ';
		}else {
			connectionTypeCondition = 'AND (ConnectionType__c = \'' + String.escapeSingleQuotes(connectionType) + '\' OR ConnectionType__c = null) ';
		}

		/*
		 *@frpanico 05/10/2021
		 *Refactoring due to PMD
		 *Il metodo queryString non viene più invocato causa warning PMD su SOQL Injection
		 *Affinchè la query funzioni correttamente e' necessario inserire singoli escapeSingleQuotes 
		*/

		/*
		String conditions = '(AdegPotDisp__c =\'' + String.escapeSingleQuotes(powerAdjustment) + '\' OR AdegPotDisp__c = null) '
		+'AND (Caliber__c = \''+ String.escapeSingleQuotes(caliber) + '\' OR Caliber__c = null) ' 
		+'AND (ComparePotRi__c = \'' + String.escapeSingleQuotes(checkPrPc) + '\' OR ComparePotRi__c = null) '
		+'AND (RequestedPhase__c = \''+ String.escapeSingleQuotes(phaseType) + '\' OR RequestedPhase__c = null) '
		+'AND (PowerEngaged__c = \'' + String.escapeSingleQuotes(rangePc) + '\' OR PowerEngaged__c = null) '
		+'AND (PowerRequired__c = \'' + String.escapeSingleQuotes(rangePr) + '\' OR PowerRequired__c = null) '
		+'AND (GdmMovement__c = \'' + String.escapeSingleQuotes(displacementDistance) + '\' or GdmMovement__c = null) '
		+'AND (VoltageRequired__c = \'' + String.escapeSingleQuotes(voltage) + '\' OR VoltageRequired__c = null) '
		+connectionTypeCondition
		+'AND Operation_type__c = \'' + String.escapeSingleQuotes(operationType) + '\' '
		+'AND Commodity__c = \'' + String.escapeSingleQuotes(commodity) + '\' '
		+'AND (EnergyUseType__c = \'' + String.escapeSingleQuotes(energyUseType) + '\' OR EnergyUseType__c = null) '
		+'AND (VendDist__c = \'' + String.escapeSingleQuotes(vendDist) + '\' OR VendDist__c = null) '
		+'AND (PhaseVoltage__c = \'' + String.escapeSingleQuotes(voltagePhase) + '\' OR PhaseVoltage__c = null)';
		String fields = 'Id,CausalCode__c, QuoteType__c,OperationCode__c';
		*/
		QuoteManagement__c returnQuote = new QuoteManagement__c();

		try 
		{

			powerAdjustment = powerAdjustment != null ? powerAdjustment : '';
			caliber = caliber != null ? caliber : '';
			checkPrPc = checkPrPc != null ? checkPrPc : '';
			phaseType = phaseType != null ? phaseType : '';
			rangePc = rangePc != null ? rangePc : '';
			rangePr = rangePr != null ? rangePr : '';
			displacementDistance = displacementDistance != null ? displacementDistance : '';
			voltage = voltage != null ? voltage : '';
			operationType = operationType != null ? operationType : '';
			commodity = commodity != null ? commodity : '';
			energyUseType = energyUseType != null ? energyUseType : '';
			vendDist = vendDist != null ? vendDist : '';
			voltagePhase = voltagePhase != null ? voltagePhase : '';

			returnQuote = Database.query('SELECT Id, CausalCode__c, QuoteType__c, OperationCode__c FROM QuoteManagement__c WHERE' +
			+'(AdegPotDisp__c =\'' + String.escapeSingleQuotes(powerAdjustment) + '\' OR AdegPotDisp__c = null) '
			+'AND (Caliber__c = \''+ String.escapeSingleQuotes(caliber) + '\' OR Caliber__c = null) ' 
			+'AND (ComparePotRi__c = \'' + String.escapeSingleQuotes(checkPrPc) + '\' OR ComparePotRi__c = null) '
			+'AND (RequestedPhase__c = \''+ String.escapeSingleQuotes(phaseType) + '\' OR RequestedPhase__c = null) '
			+'AND (PowerEngaged__c = \'' + String.escapeSingleQuotes(rangePc) + '\' OR PowerEngaged__c = null) '
			+'AND (PowerRequired__c = \'' + String.escapeSingleQuotes(rangePr) + '\' OR PowerRequired__c = null) '
			+'AND (GdmMovement__c = \'' + String.escapeSingleQuotes(displacementDistance) + '\' or GdmMovement__c = null) '
			+'AND (VoltageRequired__c = \'' + String.escapeSingleQuotes(voltage) + '\' OR VoltageRequired__c = null) '
			+connectionTypeCondition
			+'AND Operation_type__c = \'' + String.escapeSingleQuotes(operationType) + '\' '
			+'AND (Subprocess__c = \'' + String.escapeSingleQuotes(subprocess) + '\' OR Subprocess__c = null) '
			+'AND Commodity__c = \'' + String.escapeSingleQuotes(commodity) + '\' '
			+'AND (EnergyUseType__c = \'' + String.escapeSingleQuotes(energyUseType) + '\' OR EnergyUseType__c = null) '
			+'AND (VendDist__c = \'' + String.escapeSingleQuotes(vendDist) + '\' OR VendDist__c = null) '
			+'AND (PhaseVoltage__c = \'' + String.escapeSingleQuotes(voltagePhase) + '\' OR PhaseVoltage__c = null)'
			+ 'WITH SECURITY_ENFORCED LIMIT 1');
			
		} catch (Exception e) 
		{
			returnQuote = null;
		}

		return returnQuote;
		
		//return HDT_QR_QuoteManagement.queryString(fields, conditions);

	}


	public static boolean checkLocalDispatcher(String localDispatcher){
		if(localDispatcher != null && String.isNotBlank(localDispatcher)){
			Integer dispatcherList = [SELECT COUNT() FROM HDT_LocalDispatcherInrete__mdt WHERE DispatcherDesc__c =: localDispatcher WITH SECURITY_ENFORCED];
			if(dispatcherList != null && dispatcherList > 0){
				return true;
			}else{
				return false;
			}
		}
		return false;
    }
    
	public static String getRangeValue(Decimal power){
		String result = '';
		if(power != null){
			List<HDT_PowerRangeValue__mdt> powerRangeValueList = [SELECT Range__c FROM HDT_PowerRangeValue__mdt WHERE Low__c <: power AND High__c >= :power WITH SECURITY_ENFORCED];
			if(powerRangeValueList.size() > 0){
				result = powerRangeValueList[0].Range__c;
			}
		}

        return result;

	}
	
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
        public Decimal powerAvailable;
		
		@InvocableVariable
        public Decimal powerCommitted;
		
		@InvocableVariable
        public String connectionType;
		
		@InvocableVariable
        public Decimal powerRequested;
		
		@InvocableVariable
        public String supplyType;
		
		@InvocableVariable
        public String phaseType;
		
		@InvocableVariable
        public String energyUseType;
		
		@InvocableVariable
        public String displacementDistance;

		@InvocableVariable
        public String voltageAvailable;

		@InvocableVariable
        public String phaseAvalaible;

		@InvocableVariable
        public String subprocess;
    }
    

}