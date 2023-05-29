public with sharing class HDT_WRP_Scope {

    public HDT_WRP_Scope() 
    {
        this.sobjList = null;    
    }
    public HDT_WRP_Scope(List<SObject> sobjList)
    {
        this.sobjList = sobjList;
    }

    public List<SObject> sobjList;

}
