/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 28/05/2021
* @description HDT_QR_Group.cls
* @history Lorenzo – 28/05/2021 – created class
*/

public with sharing class HDT_QR_Group {
   public Group getQueueByDevelopername(String Developername){
        Group g = [Select id,developername from Group where type = 'Queue' AND Developername = :developername WITH SECURITY_ENFORCED] ;
        return g;
   }
   public List<Group> getQueueByDevelopername(List<String> Developername){ 
      List<Group> g = [Select id,developername from Group where type = 'Queue' AND Developername IN :developername WITH SECURITY_ENFORCED];
      return g;
 }
}
