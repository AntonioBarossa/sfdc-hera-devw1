/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 16/06/2021
 * @description HDT_LC_ResumeCommercialBonus
 * @history Sabina Levonja – 16/06/2021 – created class
 */
public inherited sharing class HDT_LC_ResumeCommercialBonus{
	private static HDT_QR_Case caseQr = new HDT_QR_Case();
	private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
	private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
	/**
	 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
	 * @description Get Sale to resume
	 * @param String id (Sale__c.Id)
	 * @return Map<String, Object>
	 */
	@AuraEnabled
	public static Map<String, Object> loadCase(String id){

		Map<String, Object> results = new Map<String, Object>();

		saleSrv.checkReadAccess('Account__c,Status__c');
		List<Case> cs = caseQr.getRecordsById(new List<String>{id}, 'Id, Status,Phase__c,Type');
		if (cs != null && !cs.isEmpty()){
			results.put('case', cs[0]);
		}


		return results;
	}
}