/**
* @author Erico Capozzo (enrico.capozzo@webresults.it)
* @date 12/07/2021
* @description HDT_BA_ConsentContact
* @history Erico Capozzo – 12/07/2021 – created class
*/
public without sharing class HDT_BA_ConsentContact  implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {
	
	
	public String runId;
	public String status;
	public Integer fileNumber;
	public String errorMessage;
	public List<Id> listIdContentVersion = new List<Id>();
	public Set<String> setEmailContactProcessed = new Set<String>();
	
	
	public HDT_BA_ConsentContact(Integer varFileNumber,String paramRunId,String paramStatus,String paramErrorMessage,List<Id> paramListIdContentVersion,Set<String> paramsetEmailContactProcessed){
		this.runId = paramRunId;
		this.errorMessage=paramErrorMessage;
		this.fileNumber=varFileNumber!=null?varFileNumber:0;
		this.status=String.isBlank(paramStatus)?'success':paramStatus;
		this.listIdContentVersion.addAll(paramListIdContentVersion);
		this.setEmailContactProcessed=paramsetEmailContactProcessed;
	}
	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String conditionMap='  (Email!=null OR Email!=\'\') AND (IndividualId!=null) ';
		
		if (setEmailContactProcessed!=null && !setEmailContactProcessed.isEmpty()) { 
			conditionMap =' (Email!=null OR Email!=\'\') AND (IndividualId!=null) AND Email NOT IN:setEmailContactProcessed   ';
		}
		
		String query = 'SELECT id,Email,CreatedDate,IndividualId,Individual.CreatedDate,Individual.ProfilingPrivacy__c, Individual.PrivacyProfilingChoiceDate__c FROM Contact  WHERE' + conditionMap  + ' order  by Email,Individual.PrivacyProfilingChoiceDate__c,Individual.CreatedDate';
		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext bc, List<Contact> scope) {
		//System.debug('HDT_BA_ConsentContact execute ');
		try {
			
			Map<String, Contact> mapContactByEmail = new Map<String, Contact>(); // la chiave della mappa è l'email del Contact
			String row=''; 
			
			// logica duplicati Contact start
			for (Contact tempContact : scope) {
             
				if (mapContactByEmail.get(tempContact.Email)==null) {
					mapContactByEmail.put(tempContact.Email, tempContact);
				}
				else {
					Contact actualContact=mapContactByEmail.get(tempContact.Email);
					if ( tempContact.Individual.ProfilingPrivacy__c!=null &&(tempContact.Individual.ProfilingPrivacy__c>actualContact.Individual.ProfilingPrivacy__c)) {
						mapContactByEmail.put(tempContact.Email, tempContact);
					}
					else if(tempContact.CreatedDate>actualContact.CreatedDate) {
						mapContactByEmail.remove(tempContact.Email);
					}
				}
				
			}
			// logica duplicati Contact end  
			
 
			// Controllo se ci sono altri Contact nei chunk successivi 
			List<Contact> listContactNotInChunk = [SELECT id,Email,CreatedDate,IndividualId,Individual.CreatedDate,Individual.ProfilingPrivacy__c,Individual.PrivacyProfilingChoiceDate__c FROM Contact WHERE  (Email IN:mapContactByEmail.keySet() )AND (Id NOT IN :mapContactByEmail.values() AND IndividualId!=null) ORDER BY Email,Individual.PrivacyProfilingChoiceDate__c,Individual.CreatedDate];
            if (listContactNotInChunk!=null && !listContactNotInChunk.isEmpty()) {	
				for (Contact tempContact : listContactNotInChunk) {
					Contact actualContact=mapContactByEmail.get(tempContact.Email);
					if ( mapContactByEmail.get(tempContact.Email)!=null
					&&
					tempContact.Individual.PrivacyProfilingChoiceDate__c!=null
					&&
					(tempContact.Individual.PrivacyProfilingChoiceDate__c>actualContact.Individual.PrivacyProfilingChoiceDate__c)) {
						mapContactByEmail.remove(tempContact.Email);
					}
					else if(actualContact!=null&&tempContact.CreatedDate>actualContact.CreatedDate) {
						mapContactByEmail.remove(tempContact.Email);
					}
				}
			}
			
			for (Contact tempContact : mapContactByEmail.values()) { 
				// Controllo se il ProfilingPrivacy è presente viene inserito 1 solo se ProfilingPrivacy=SI altrimenti 0
				String privacyFlag= 'SI'.equalsIgnoreCase(tempContact.Individual.ProfilingPrivacy__c)?'1':'0';
				
				date tmpDate;
				String privacyProfilingChoiceDateTime;
				tmpDate = tempContact.Individual.PrivacyProfilingChoiceDate__c!=null?tempContact.Individual.PrivacyProfilingChoiceDate__c:tempContact.Individual.CreatedDate.date(); 
				privacyProfilingChoiceDateTime= String.valueOf(  DateTime.newInstance(tmpDate.year(), tmpDate.month(),tmpDate.day(), 0, 0, 0).getTime());
				// inserisco la riga
				row=String.isBlank(row)?row:row+'\n';
				row=row+'bk^email_sha256^'+HDT_UTL_Utils.codingSha256(tempContact.Email)+'^set^gdpr^dc='+privacyFlag+'&tg='+privacyFlag+'&al='+privacyFlag+'&cd='+privacyFlag+'&sh='+privacyFlag+'&re='+privacyFlag+'^'+privacyProfilingChoiceDateTime;
				
			}
			
			
			
			if (String.isNotBlank(row)) {
				
				Blob generateFileBlob = Blob.valueof(row);
				ContentVersion cv = new ContentVersion();
				cv.ContentLocation = 'S';
				cv.VersionData = generateFileBlob;
				Date runDate= Date.today();
				cv.Title = 'heradmp_firstpartydata_'+String.valueOf( runDate.year())+String.valueOf( runDate.month())+String.valueOf( runDate.day())+'_'+String.valueOf(this.fileNumber);
				cv.PathOnClient = 'heradmp_firstpartydata_'+String.valueOf( runDate.year())+String.valueOf( runDate.month())+String.valueOf( runDate.day())+'_'+String.valueOf(fileNumber)+'.csv';
				insert cv;
				fileNumber=fileNumber+1;
				listIdContentVersion.add(cv.Id);
			}
		} 
		catch (Exception e) {
			//System.debug('Exception : '+e.getMessage());
			status='failed';
			errorMessage=e.getMessage();
		}
	}
	
	public void finish(Database.BatchableContext bc){
		//System.debug('Finish HDT_BA_ConsentContact ');
		
		HDT_WS_CampagenDmDmp.callService(runId,status,'CMPDMP_PRV',errorMessage,listIdContentVersion);
	}
}