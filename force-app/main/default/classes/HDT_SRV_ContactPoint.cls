/**
 * @author Sabina Levonja (sabinalevonja@dunegroup.it)
 * @date 21/04/2021
 * @description HDT_SRV_ContactPoint Test Classes
 * @history Sabina Levonja 21/04/2021 – Created Class
 */

public with sharing class HDT_SRV_ContactPoint {
    private static final String UPDATEPERMISSION = 'update';
    private static final String UPSERTPERMISSION = 'upsert';
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();

    /* The methods were commented as not used anywhere in the code. 
    Furthermore, if the methods were ever needed it is necessary to split them in 2 
    making a specific method for ContactPointPhone and one for ContactPointEmail
    */

    // public static void checkAccessInit(String fields, String crud){
    //     HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ContactPoint', fields, crud);
    //     securityAccess.checkSecurityAccess();
    // }

    // public void checkUpsertAccess(String fields){
    //     checkAccessInit(fields, UPSERTPERMISSION);
    // }

    /**
     * @author Elfrida Kora(elfrida.kora@dunegroup.it)
     * @description Check if user has create access to fields and throw exception if access not granted
     */

    public static void upsertContactPointEmail(List<ContactPointEmail> contactPointEmailList){
        

        HDT_SRV_ContactPointEmail.upsertRecord(contactPointEmailList);

    }

    public static void upsertContactPointPhone(List<ContactPointPhone> contactPointPhoneList){
        List<ContactPointPhone> contPointPhoneList = new List<ContactPointPhone>();
        for(ContactPointPhone cpp: contactPointPhoneList){
        contPointPhoneList.add(cpp);
        
        }

        HDT_SRV_ContactPointPhone.upsertRecord(contPointPhoneList);

    }

    public static void updateContactPointEmail(List<ContactPointEmail> contactPointEmailList){
        List<ContactPointEmail> contPointEmailList = new List<ContactPointEmail>();
        for(ContactPointEmail cpe: contactPointEmailList){
        contPointEmailList.add(cpe);
        
        }

        HDT_SRV_ContactPointEmail.updateRecord(contPointEmailList);   

    }

    public static void updateContactPointPhone(List<ContactPointPhone> contactPointPhoneList){
        List<ContactPointPhone> contPointPhoneList = new List<ContactPointPhone>();
        for(ContactPointPhone cpp: contactPointPhoneList){
        contPointPhoneList.add(cpp);
        
        }

        HDT_SRV_ContactPointPhone.updateRecord(contPointPhoneList);   

    }
}
