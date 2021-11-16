public class HDT_UTL_MockInterfaceOverrideTst extends HDT_UTL_MockInterfaceTst{
	final List<SObject> OBJECT_LIST;
    
@TestVisible
HDT_UTL_MockInterfaceOverrideTst(List<SObject> mockRecords){
	this.OBJECT_LIST = mockRecords;
}
public override List<SObject> passThrough(List<SObject> records){
	return OBJECT_LIST;
}
}