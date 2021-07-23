public with sharing class HDT_QR_Group {
   public Group getQueueByDevelopername(String Developername){
        Group g = [Select id,developername from Group where type = 'Queue' AND Developername = :developername];
        return g;
   }
   public List<Group> getQueueByDevelopername(List<String> Developername){
      List<Group> g = [Select id,developername from Group where type = 'Queue' AND Developername IN :developername];
      return g;
 }
}
