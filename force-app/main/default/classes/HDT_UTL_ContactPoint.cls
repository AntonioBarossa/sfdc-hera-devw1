public with sharing class HDT_UTL_ContactPoint {
    
    public static ContactPointEmail instanceContactPointEmail(String email, Boolean isPrimary) {
       
        ContactPointEmail contEmail= new ContactPointEmail(EmailAddress= email ,IsPrimary = isPrimary,Type__c = 'E-mail Anagrafica');
        return contEmail;

    }

     /**
     * @author Elfrida Kora(elfrida.kora@dunegroup.it)
     */


    public static List<ContactPointEmail> createContactPointEmail(String primaryEmail,Id IndividualId,List<String> otherEmails){
        List<ContactPointEmail> emailsList = new List<ContactPointEmail>();
        
        if(
             !String.isblank(primaryEmail)
        ) {
            ContactPointEmail emailCont= instanceContactPointEmail( primaryEmail, true);
            emailCont.ParentId = individualId;
            emailsList.add(emailCont);
        }          
        for(String email: otherEmails){
           ContactPointEmail emailContact= instanceContactPointEmail( email, false);
           emailContact.ParentId = individualId;
           emailsList.add(emailContact);
        }
        //Aggiungere insert della lista 
        HDT_SRV_ContactPoint.upsertContactPointEmail(emailsList);
        return emailsList;
        }
        public static List<ContactPointEmail> createContactPointEmail(Map<String,String> primaryEmail,Map<String,List<String>> emails){
            List<ContactPointEmail> emailsList = new List<ContactPointEmail>();
            
            for(String id: primaryEmail.keySet()){
                if( !String.isblank(primaryEmail.get(id))) {
                    ContactPointEmail emailCont= instanceContactPointEmail( primaryEmail.get(id), true);
                    emailCont.ParentId = id;
                    emailsList.add(emailCont);
                }
            }

            for(String id: emails.keySet()){
                List<String> email= emails.get(id);
                if(email.size()>0){
                    for(String em: email){
                        if(!String.isblank(em)){
                            ContactPointEmail emailContact= instanceContactPointEmail( em, false);
                            emailContact.ParentId = id;
                            emailsList.add(emailContact);
                        }
                    }
                }
            }
        //Aggiungere insert della lista 
        HDT_SRV_ContactPoint.upsertContactPointEmail(emailsList);
        return emailsList;
        }

        public static ContactPointPhone instanceContactPointPhone(String phone, String prefix, Boolean isPrimary) {
        
       
            ContactPointPhone contPhone= new ContactPointPhone(TelephoneNumber=phone ,Prefix__c= prefix,IsPrimary = isPrimary);
            return contPhone;
    
        }

        // public static List<ContactPointPhone> createContactPointPhone(String primaryPhone, Id IndividualId , List<String> otherPhones){
        //     List<ContactPointPhone> phonesList = new List<ContactPointPhone>();
        //     if(
        //         !String.isblank(primaryPhone)
        //     ){
        //         ContactPointPhone phoneCont= instanceContactPointPhone( primaryPhone, true);
        //         phoneCont.ParentId = individualId;
        //         phonesList.add(phoneCont);
        //     }          
        //        for(String phone: otherPhones){
        //           ContactPointPhone phoneContact= instanceContactPointPhone(phone,false);
        //           phoneContact.ParentId = individualId;
        //           phonesList.add(phoneContact);
        //     }
        //     HDT_SRV_ContactPoint.upsertContactPointPhone(phonesList);
        //     return phonesList;
        // }
    // public static List<ContactPointPhone> createContactPointPhone(String primaryPhone, Id IndividualId , List<String> otherPhones,String tipologia){
    //     List<ContactPointPhone> phonesList = new List<ContactPointPhone>();
    //     if(
    //         !String.isblank(primaryPhone)
    //     ){
    //         ContactPointPhone phoneCont= instanceContactPointPhone( primaryPhone, true);
    //         phoneCont.ParentId = individualId;
    //         phoneCont.Type__c = tipologia;
    //         phonesList.add(phoneCont);
    //     }          
    //     for(String phone: otherPhones){
    //         ContactPointPhone phoneContact= instanceContactPointPhone(phone,false);
    //         phoneContact.ParentId = individualId;
    //         phoneContact.type__c = tipologia;
    //         phonesList.add(phoneContact);
    //     }
    //     HDT_SRV_ContactPoint.upsertContactPointPhone(phonesList);
    //     return phonesList;
    // }


    public static List<ContactPointPhone> createContactPointPhone( Map<String,String> primary,Map<String,List<String>> phones,Map<String,String> prefixes,String tipologia){
        List<ContactPointPhone> phonesList = new List<ContactPointPhone>();

        for(String id: primary.keySet()){
            ContactPointPhone phoneCont= instanceContactPointPhone( primary.get(id),prefixes.get(primary.get(id)), true);
            phoneCont.ParentId = id;
            phoneCont.Type__c = tipologia;
            phonesList.add(phoneCont);
        }
        for(String id: phones.keySet()){
            List<String> phone= phones.get(id);
            if(phone.size()>0){
                for(String p: phone){
                    if(!String.isblank(p)){
                        ContactPointPhone phoneContact= instanceContactPointPhone( p, prefixes.get(p), false);
                        phoneContact.ParentId = id;
                        phoneContact.Type__c = tipologia;
                        phonesList.add(phoneContact);
                    }
                }
            }
        }
        HDT_SRV_ContactPoint.upsertContactPointPhone(phonesList);
        return phonesList;

    }

                
        public static List<ContactPointEmail> instanceMultiContactPointEmail(List<String> emailList,Boolean isPrimary){
            List<ContactPointEmail> emailsList = new List<ContactPointEmail>();
            for(String email:emailList){
                emailsList.add(instanceContactPointEmail(email,isPrimary));

            }
            return emailsList;
        }

        // public static List<ContactPointPhone> instanceMultiContactPointPhone(List<String> phoneList,Boolean isPrimary){
        //     List<ContactPointPhone> phonesList  = new List<ContactPointPhone>();
        //     for(String phone:phoneList){
        //         phonesList.add(instanceContactPointPhone(phone,isPrimary));
        //     }

            
        //     return phonesList;
        // }
        
        public static List<ContactPointPhone> verifyContactPointPhone(Id IndividualId,List<String> phoneList){
            List<ContactPointPhone> phonesList  = new List<ContactPointPhone>();
            for(String phone:phoneList){
                ContactPointPhone phoneContact = new ContactPointPhone (ParentId=IndividualId,TelephoneNumber=phone);
                phonesList.add(phoneContact);

            }

            return phonesList;

        }

        public static List<ContactPointEmail> verifyContactPointEmail(Id IndividualId,List<String> emailList){
            List<ContactPointEmail> emailsList = new List<ContactPointEmail>();
            for(String email:emailList){
                ContactPointEmail emailContact = new ContactPointEmail(ParentId=IndividualId,EmailAddress=email);
                emailsList.add(emailContact);
            }

            return emailsList;
        }
}
