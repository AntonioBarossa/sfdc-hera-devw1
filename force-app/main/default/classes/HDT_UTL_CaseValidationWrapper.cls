public class HDT_UTL_CaseValidationWrapper {
    public String outcomeCode{ get; set; }
    public String outcomeDescription{ get; set; }

    public HDT_UTL_CaseValidationWrapper(String outcomeCode, String outcomeDescription){
        this.outcomeCode = outcomeCode;
        this.outcomeDescription = outcomeDescription;
    }
}