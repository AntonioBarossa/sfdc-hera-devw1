public inherited sharing class HDT_QR_ContactPoint {

    public static ContactPointPhone getContactPhoneById (Id contactPhoneId, String fields){
        ContactPointPhone res;

        String query = 'SELECT '+ fields +
                ' FROM ContactPointPhone WHERE Id = :contactPhoneId LIMIT 1';
        List <ContactPointPhone> contphone = Database.query(query);

        if(contPhone != null && contPhone.size() > 0){
			res = contphone[0];
		}
		else{
			res = null;
		}
        return res;
    }

    /**
     * @author Elfrida Kora (elfrida.kora@dunegroup.it)
     * @description Get ContactPoint Email/Phone by Id,Email,Individual
     * @param String id
     * @param String Fields
     * @param String Phone
     * @param String Email
     * @param Id individualId
     */
    
    public static ContactPointPhone getPrimaryContactEmailByIndividual (Id individualId, String fields){
        ContactPointPhone res;

        String query = 'SELECT '+ fields +
                ' FROM ContactPointPhone WHERE ParentId = :individualId LIMIT 1';
        List <ContactPointPhone> contphone = Database.query(query);

        if(contPhone != null && contPhone.size() > 0){
			res = contphone[0];
		}
		else{
			res = null;
		}
        return res;
    }
    

    public static List<ContactPointPhone> getIndividualContactPhoneList (Id individualId, String fields){

        String query = 'SELECT '+ fields +
                ' FROM ContactPointPhone WHERE ParentId = :individualId ';
        List <ContactPointPhone> contphone = Database.query(query);

        return contphone;

    }
    
     public static List<ContactPointPhone> getIndividualContactsPhoneList (List<String> individualId, String fields){

        String query = 'SELECT '+ fields +
                ' FROM ContactPointPhone WHERE ParentId IN :individualId ';
        List <ContactPointPhone> contphone = Database.query(query);

        return contphone;

    }
    
    public static List<ContactPointEmail> getIndividualContactsEmailList (List<String> individualId, String fields){

        String query = 'SELECT '+ fields +
                ' FROM ContactPointEmail WHERE ParentId IN :individualId ';
        List <ContactPointEmail> contemail = Database.query(query);

        return contemail;

    }
    
    public static List<ContactPointEmail> getIndividualContactEmailList (Id individualId, String fields){

        String query = 'SELECT '+ fields +
                ' FROM ContactPointEmail WHERE ParentId = :individualId ';
        List <ContactPointEmail> contemail = Database.query(query);

        return contemail;

    }

    public static ContactPointPhone getContactEmailByPhone (String phone, Id individualId, String fields){
        ContactPointPhone res;

        String query = 'SELECT '+ fields +
                ' FROM ContactPointPhone WHERE ParentId = :individualId LIMIT 1';
        List <ContactPointPhone> contphone = Database.query(query);

        if(contPhone != null && contPhone.size() > 0){
			res = contphone[0];
		}
		else{
			res = null;
		}
        return res;
    }

    public static ContactPointPhone getContactEmailById (Id contactEmailId, String fields){
		
		ContactPointPhone res;
		
        String query = 'SELECT '+ fields +
                ' FROM ContactPointPhone WHERE Id = :contactEmailId LIMIT 1';
        List <ContactPointPhone> contphone = Database.query(query);
		if(contPhone != null && contPhone.size() > 0){
			res = contphone[0];
		}
		else{
			res = null;
		}
        return res;
    }


       
    public static ContactPointEmail searchContactPointEmail (String email){
        ContactPointEmail res;
        String query = 'SELECT Id FROM ContactPointEmail WHERE EmailAddress  = :email';
        List <ContactPointEmail> contemail = Database.query(query);
        
        if(contEmail != null && contEmail.size() > 0){
			res = contemail[0];
		}
		else{
			res = null;
		}
        return res;
    }

    public static List<ContactPointPhone> searchPointPhone (String ParentId){
        
        String query = 'SELECT Id FROM ContactPointPhone WHERE ParentId  = :ParentId';
        List <ContactPointPhone> contphone = Database.query(query);
        return contphone;
            
    }
    
    public static ContactPointPhone searchContactPointPhone (String phone){
        ContactPointPhone res;
        String query = 'SELECT Id FROM ContactPointPhone WHERE PhoneType = :phone';
        List <ContactPointPhone> contphone = Database.query(query);
        if(contPhone != null && contPhone.size() > 0){
			res = contphone[0];
		}
		else{
			res = null;
		}
        return res; 
   }
    public static List<ContactPointEmail> searchPointEmail (String ParentId){
        
        String query = 'SELECT Id FROM ContactPointEmail WHERE ParentId  = :ParentId';
        List <ContactPointEmail> contemail = Database.query(query);
        return contemail;
            
    }

//     public static ContactPointEmail getoldcontactemail (String id,String email){
//         ContactPointEmail res;
//         String query = 'SELECT Id,Status__c FROM ContactPointEmail WHERE ParentId = :id AND EmailAddress= :email';
//         List <ContactPointEmail> contemail = Database.query(query);
//         if(contemail != null && contemail.size() > 0){
// 			res = contemail[0];
// 		}
// 		else{
// 			res = null;
// 		}
//         return res; 
//    }
   
   public static List<ContactPointEmail> getOldContactEmails(List<String> id,List<String> email){
        String query = 'SELECT Id,Status__c, ParentId FROM ContactPointEmail WHERE ParentId IN :id AND EmailAddress IN :email';
        List <ContactPointEmail> contemail = Database.query(query);
        return contemail; 
    }

    // public static ContactPointPhone getoldcontactphone (String id,String phone){
    //     ContactPointPhone res;
    //     String query = 'SELECT Id,Status__c FROM ContactPointPhone WHERE ParentId = :id AND TelephoneNumber= :phone';
    //     List <ContactPointPhone> contphone = Database.query(query);
    //     if(contphone != null && contphone.size() > 0){
    //         res = contphone[0];
    //     }
    //     else{
    //         res = null;
    //     }
    //     return res; 
    // }

    public static List<ContactPointPhone> getOldContactsPhone (List<String> id,List<String> phone){

        String query = 'SELECT Id,Status__c, ParentId FROM ContactPointPhone WHERE ParentId IN :id AND TelephoneNumber IN :phone';
        List <ContactPointPhone> contphone = Database.query(query);
        return contphone; 
    }
    
}