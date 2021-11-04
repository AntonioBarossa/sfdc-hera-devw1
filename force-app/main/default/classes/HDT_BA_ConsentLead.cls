public without sharing  class HDT_BA_ConsentLead   implements Database.Batchable<SObject> , Database.Stateful,Database.AllowsCallouts {
   

		public String runId;
		public String status;
		public Integer fileNumber;
		public String errorMessage;
		public List<Id> listIdContentVersion = new List<Id>();
		public Set<String> setEmailContactProcessed = new Set<String>();

		
		public HDT_BA_ConsentLead(String paramRunId){
		   this.runId=paramRunId;
		   this.fileNumber=0;
		}
	
		public Database.QueryLocator start(Database.BatchableContext bc) {
			String query = 'SELECT id,Email,Status,CreatedDate,IsConverted,IndividualId,Individual.ProfilingPrivacy__c,Individual.CreatedDate,Individual.PrivacyProfilingChoiceDate__c FROM Lead WHERE (IsConverted=false) AND (Email!=null OR Email!=\'\')AND Status!=\'Expired\' AND IndividualId!=null ORDER BY Email,Individual.PrivacyProfilingChoiceDate__c,Individual.CreatedDate';
			return Database.getQueryLocator(query);
		}
	
		public void execute(Database.BatchableContext bc, List<Lead> scope) {
			//System.debug('HDT_BA_ConsentLead execute ');
			status='success';
			try {
				
				
				Map<String, Lead> mapLeadByEmail       = new Map<String, Lead>();
				Map<String, Contact> mapContactByEmail = new Map<String, Contact>();
				List<Contact> listContacts             = new List<Contact>();
				
				// logica duplicati start
				for (Lead tempLead : scope) {
				
					if (mapLeadByEmail.get(tempLead.Email)==null) {
						mapLeadByEmail.put(tempLead.Email, tempLead);
					}

					else {
						Lead actualLead=mapLeadByEmail.get(tempLead.Email);
						if ( tempLead.Individual.PrivacyProfilingChoiceDate__c!=null
							&&(tempLead.Individual.PrivacyProfilingChoiceDate__c>actualLead.Individual.PrivacyProfilingChoiceDate__c)) {
								mapLeadByEmail.put(tempLead.Email, tempLead);
						}
						else if(tempLead.CreatedDate>actualLead.CreatedDate) {
							    mapLeadByEmail.put(tempLead.Email, tempLead);
						}
					}
				}
				// logica duplicati end

				if (!setEmailContactProcessed.isEmpty()) {
					mapLeadByEmail.keySet().removeAll(setEmailContactProcessed); //rimuovo dalla mappa i lead già processati
				}

				// controllo se sono presenti contact con la stessa email dei lead che sto processando
				if (!mapLeadByEmail.isEmpty()) {
					listContacts = [SELECT id,email,CreatedDate,IndividualId,Individual.ProfilingPrivacy__c,Individual.CreatedDate,Individual.PrivacyProfilingChoiceDate__c  FROM Contact WHERE Email IN:mapLeadByEmail.keySet() AND IndividualId!=null ORDER BY Email,Individual.PrivacyProfilingChoiceDate__c,Individual.CreatedDate ]; 	
				}
			 	
				// logica duplicati Contact start
				for (Contact tempContact : listContacts) {

					if (mapContactByEmail.get(tempContact.Email)==null) {
						mapContactByEmail.put(tempContact.Email, tempContact);
					}
					else {
						Contact actualContact=mapContactByEmail.get(tempContact.Email);

						if ( tempContact.Individual.PrivacyProfilingChoiceDate__c!=null
							&&(tempContact.Individual.PrivacyProfilingChoiceDate__c>actualContact.Individual.PrivacyProfilingChoiceDate__c)) {
							mapContactByEmail.put(tempContact.Email, tempContact);
						}
						else if(tempContact.CreatedDate>actualContact.CreatedDate) {
							mapContactByEmail.put(tempContact.Email, tempContact);
						}
					}
					setEmailContactProcessed.add(tempContact.email);
				}
				// logica duplicati Contact end



				String row='';
				if (!mapContactByEmail.isEmpty()) {
					mapLeadByEmail.keySet().removeAll(mapContactByEmail.keySet()); // rimuovo tutti i lead che contengono la stessa email dei Contact già elaborati

					for (Contact tempContact : mapContactByEmail.values()) { 
						// Controllo se il ProfilingPrivacy è presente viene inserito 1 solo se ProfilingPrivacy=SI altrimenti 0
						String privacyFlag='SI'.equalsIgnoreCase(tempContact.Individual.ProfilingPrivacy__c)?'1':'0';
						date tmpDate;
						String privacyProfilingChoiceDateTime;
						tmpDate = tempContact.Individual.PrivacyProfilingChoiceDate__c!=null?tempContact.Individual.PrivacyProfilingChoiceDate__c:tempContact.Individual.CreatedDate.date(); 
						privacyProfilingChoiceDateTime= String.valueOf(  DateTime.newInstance(tmpDate.year(), tmpDate.month(),tmpDate.day(), 0, 0, 0).getTime());

						row=String.isBlank(row)?row:row+'\n';
						row=row+'bk^email_sha256^'+HDT_UTL_Utils.codingSha256(tempContact.Email)+'^set^gdpr^dc='+privacyFlag+'&tg='+privacyFlag+'&al='+privacyFlag+'&cd='+privacyFlag+'&sh='+privacyFlag+'&re='+privacyFlag+'^'+privacyProfilingChoiceDateTime;

					}
				}


				/* controllo se ci sono altri lead nei chunk successivi 
				   il controllo viene inserito qui perchè nel caso già sia presente un contact viene rimosso dalla mappa mapLeadByEmail 
				*/
				List<Lead> listLeadNotInChunk = [SELECT id,Email,CreatedDate,IndividualId,status,IsConverted,Individual.CreatedDate,Individual.ProfilingPrivacy__c,Individual.PrivacyProfilingChoiceDate__c FROM Lead WHERE (IsConverted=false)AND Status != 'Expired' AND (Email IN:mapLeadByEmail.keySet() AND Id NOT IN :mapLeadByEmail.values()) ORDER BY  Email,Individual.PrivacyProfilingChoiceDate__c,Individual.CreatedDate];

				if (listLeadNotInChunk!=null && !listLeadNotInChunk.isEmpty()) {	
					for (Lead tempLead : listLeadNotInChunk) {
						Lead actualLead=mapLeadByEmail.get(tempLead.Email);
						if ( mapLeadByEmail.get(tempLead.Email)!=null
							&&
							tempLead.Individual.PrivacyProfilingChoiceDate__c!=null
							&&
							(tempLead.Individual.PrivacyProfilingChoiceDate__c>actualLead.Individual.PrivacyProfilingChoiceDate__c)) {
							//mapLeadByEmail.put(tempLead.Email, tempLead);//
							mapLeadByEmail.keySet().remove(tempLead.Email); // verrà aggiunto nel prossimo chunk
						}
						else if(actualLead!=null &&tempLead.CreatedDate>actualLead.CreatedDate){
							mapLeadByEmail.keySet().remove(tempLead.Email); // verrà aggiunto nel prossimo chunk
						} 
					}
				}



				for (Lead tempLead : mapLeadByEmail.values()) { 
					String privacyFlag='SI'.equalsIgnoreCase(tempLead.Individual.ProfilingPrivacy__c)?'1':'0';
					date tmpDate;
					String privacyProfilingChoiceDateTime;
					tmpDate = tempLead.Individual.PrivacyProfilingChoiceDate__c!=null?tempLead.Individual.PrivacyProfilingChoiceDate__c:tempLead.Individual.CreatedDate.date(); 
					privacyProfilingChoiceDateTime= String.valueOf(  DateTime.newInstance(tmpDate.year(), tmpDate.month(),tmpDate.day(), 0, 0, 0).getTime());

					row=String.isBlank(row)?row:row+'\n';
					row=row+'bk^email_sha256^'+HDT_UTL_Utils.codingSha256(tempLead.Email)+'^set^gdpr^dc='+privacyFlag+'&tg='+privacyFlag+'&al='+privacyFlag+'&cd='+privacyFlag+'&sh='+privacyFlag+'&re='+privacyFlag+'^'+privacyProfilingChoiceDateTime;

				}
			

				if (String.isNotBlank(row)) {

				
					Blob generateFileBlob = Blob.valueof(row);
					ContentVersion cv = new ContentVersion();
					cv.ContentLocation = 'S';
					cv.VersionData = generateFileBlob;
					Date runDate= Date.today();
					// il nome heradmp_firstpartydata_ potrebbe essere reso dinamico 
					cv.Title = 'heradmp_firstpartydata_'+String.valueOf( runDate.year())+String.valueOf( runDate.month())+String.valueOf( runDate.day())+'_'+String.valueOf(fileNumber);
					cv.PathOnClient = 'heradmp_firstpartydata_'+String.valueOf( runDate.year())+String.valueOf( runDate.month())+String.valueOf( runDate.day())+'_'+String.valueOf(fileNumber)+'.csv';
					insert cv;
					fileNumber=fileNumber+1;
					listIdContentVersion.add(cv.Id);
		  		}	  
			} catch (Exception e) {
				//System.debug('Exception : '+e.getMessage());
				status='failed';
				errorMessage=e.getMessage();
			}
		}
		
		public void finish(Database.BatchableContext bc){
			
			HDT_BA_ConsentContact consentContact = new HDT_BA_ConsentContact(fileNumber,runId,status,errorMessage,listIdContentVersion,setEmailContactProcessed); 
			Database.executeBatch(consentContact,1000);

		}
}