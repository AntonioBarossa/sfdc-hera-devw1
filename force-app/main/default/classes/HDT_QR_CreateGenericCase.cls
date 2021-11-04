public inherited sharing class HDT_QR_CreateGenericCase {

    /*
    * @Author: Salvatore A. Sarà 21/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public List<RecordType> getRecordTypeByDevName(String devName){

        List<RecordType> rtList = new List<RecordType>();

        try{

            rtList = [SELECT Id, Name 
            FROM RecordType
            WHERE DeveloperName = :devName
            WITH SECURITY_ENFORCED];

        }catch(Exception e){

            System.debug(LoggingLevel.DEBUG, 'HDT_QR_CreateGenericCase Exception--> '+e.getMessage());

        }

        return rtList;
    }


}
