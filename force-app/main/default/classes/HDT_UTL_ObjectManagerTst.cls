public class HDT_UTL_ObjectManagerTst{
//We create a static instance of the class that can be overridden
static HDT_UTL_MockInterfaceTst instance = new HDT_UTL_MockInterfaceTst();
/*
@description Method that returns the records that are passed to it
**********************************************************************************************/
public static List<SObject> records(List<SObject> records){
	return instance.passThrough(records);
}
/*
@description Method that is usable in a test class. Used to set the mock (SObject type) that this class will return.
**********************************************************************************************/
@TestVisible static void setMock(HDT_UTL_MockInterfaceTst mock){
	instance = mock;
}
}