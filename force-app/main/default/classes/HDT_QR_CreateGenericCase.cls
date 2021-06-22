public inherited sharing class HDT_QR_CreateGenericCase {

    public List<RecordType> getRecordTypeByDevName(String devName){

        List<RecordType> rtList = new List<RecordType>();

        try{

            rtList = [SELECT Id, Name 
            FROM RecordType
            WHERE DeveloperName = :devName
            WITH SECURITY_ENFORCED];

        }catch(Exception e){

            System.debug('HDT_QR_CreateGenericCase Exception--> '+e.getMessage());

        }

        return rtList;
    }


}
