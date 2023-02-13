public with sharing class HDT_UTL_LicenseAssignment {
    /**
     * Marco Ficorella - NTTDATA 13/02/2023
     * Classe per l'assegnazione automatica delle licenze CRM e Service
     * Da eseguire manualmente.
     *  
     **/
    public static void assignLicense(){
        //Recupero nome licenza CPQ
        PermissionSetLicense cpqLicId=[select id from PermissionSetLicense where MasterLabel ='Salesforce CPQ License' ];

        System.debug('LIC CPQ ID:'+cpqLicId.Id);

        //Recupero permissionset CPQ
        PermissionSet psCPQ=[select id from PermissionSet where LicenseId  in (select id from PermissionSetLicense where MasterLabel ='Salesforce CPQ License')  and name='HDT_SalesforceCPQLicense'];

        System.debug('PS CPQ ID:'+psCPQ.Id);

        //Recupero nome licenza CRM
        PermissionSetLicense crmLicId=[select id from PermissionSetLicense where MasterLabel ='CRM User' ];

        System.debug('LIC CRM id:'+crmLicId.Id);

        //Recupero permissionset CRM
        PermissionSet psCRM=[select id from PermissionSet where LicenseId  in (select id from PermissionSetLicense where MasterLabel ='CRM User')];

        System.debug('PS CRM ID:'+psCRM.Id);

        //Recupero nome licenza Service
        PermissionSetLicense servLicId=[select id from PermissionSetLicense where MasterLabel ='Service User' ];

        System.debug('LIC SERVICE ID:'+servLicId.Id);

        //Recupero permissionset Service
        PermissionSet psService=[select id from PermissionSet where LicenseId  in (select id from PermissionSetLicense where MasterLabel ='Service User')];

        System.debug('PS SERVICE ID:'+psService.Id);

        //Recupero utenti con il permission set CPQ
        List<PermissionSetLicenseAssign> userLicenseAssignmentCpq=[select id,AssigneeId from PermissionSetLicenseAssign  where PermissionSetLicense.DeveloperName ='SalesforceCPQ_CPQStandardPerm' and Assignee.Profile.name in ('HERA Standard User','Hera Standard User OneShot') and Assignee.isActive=true];

        System.debug('USER CON License CPQ:'+userLicenseAssignmentCpq.size());

        Set<Id> userCpq=new Set<Id>();

        for(PermissionSetLicenseAssign psal:userLicenseAssignmentCpq){
            userCpq.add(psal.AssigneeId);
        }

        //Recupero utenti con il permission set CRM
        List<PermissionSetLicenseAssign> userLicenseAssignmentCrm=[select id,AssigneeId from PermissionSetLicenseAssign  where PermissionSetLicense.DeveloperName ='CRMUserPsl' and Assignee.Profile.name in ('HERA Standard User','Hera Standard User OneShot') and Assignee.isActive=true];

        System.debug('USER CON License CRM:'+userLicenseAssignmentCrm.size());

        Set<Id> userCrm=new Set<Id>();

        for(PermissionSetLicenseAssign psalc:userLicenseAssignmentCrm){
            userCrm.add(psalc.AssigneeId);
        }


        //Recupero utenti con il permission set Service
        List<PermissionSetLicenseAssign> userLicenseAssignmentService=[select id,AssigneeId from PermissionSetLicenseAssign  where PermissionSetLicense.DeveloperName ='ServiceUserPsl' and Assignee.Profile.name in ('HERA Standard User','Hera Standard User OneShot') and Assignee.isActive=true];

        System.debug('USER CON License SERVICE:'+userLicenseAssignmentService.size());

        Set<Id> userService=new Set<Id>();

        for(PermissionSetLicenseAssign psals:userLicenseAssignmentService){
            userService.add(psals.AssigneeId);
        }

        //All User Standard and oneShot
        List<User> allUserList=[select id from user where IsActive=true and Profile.name in ('HERA Standard User','Hera Standard User OneShot')];

        System.debug('TUTTI GLI USER ATTIVI:'+allUserList.size());

        List<PermissionSetAssignment> psAssignmentList=new List<PermissionSetAssignment>();

        Integer userToAddCrm=0;
        Integer userToAddService=0;

        for(User usr:allUserList){
            
            //controllo se l'utente ha la licenza CPQ ma non la licenza Service e CRM
            if(userCpq.contains(usr.Id) && !userCrm.contains(usr.Id) && !userService.contains(usr.Id)){
                //gli devo aggiungere la CRM
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = psCRM.Id, AssigneeId = usr.Id);
                psAssignmentList.add(psa);
                userToAddCrm=userToAddCrm+1;
                continue;
            }

            //controllo se l'utente non ha la CPQ e non ha ne la CRM ne la SERVICE
            if(!userCpq.contains(usr.Id) && !userCrm.contains(usr.Id) && !userService.contains(usr.Id)){
                //gli devo aggiungere la Service
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = psService.Id, AssigneeId = usr.Id);
                psAssignmentList.add(psa);
                userToAddService=userToAddService+1;
                continue;
            }
            
            
        }

        System.debug('CRM DA ASSEGNARE:'+userToAddCrm);
        System.debug('SERVICE DA ASSEGNARE:'+userToAddService);
        System.debug('PS DA ASSEGNARE:'+psAssignmentList.size());


        insert psAssignmentList;

    }
}
